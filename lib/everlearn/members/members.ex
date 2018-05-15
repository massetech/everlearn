defmodule Everlearn.Members do
  import Ecto.Query, warn: false
  import Everlearn.{CustomMethods}
  require Logger
  require Poison

  alias Ueberauth.Auth
  alias Everlearn.Members.{Language, User, Membership, Memory}
  alias Everlearn.Contents.{PackLanguage, Item, Classroom, Pack, Card}
  alias Everlearn.{Repo, QueryFilter, Contents}

  # -------------------------------- UEBERAUTH ----------------------------------------
  # QUERIES ------------------------------------------------------------------
  # METHODS ------------------------------------------------------------------
  def sign_in_user(%Auth{} = auth) do
    insert_or_update_user(basic_info(auth))
  end

  defp insert_or_update_user(params) do
    case Repo.get_by(User, email: params.email) do
      nil ->
        # This user doesnt exist
        case create_user(params) do
          {:ok, user} -> {:created, user}
          {:error, changeset} -> {:error, changeset}
        end
      user ->
        # This user exists
        case update_user(user, params) do
          {:ok, user} -> {:updated, user}
          {:error, changeset} -> {:error, changeset}
        end
    end
  end

  defp basic_info(auth) do
    %{uid: auth.uid, token: token_from_auth(auth), token_expiration: exp_token_from_auth(auth), provider: Atom.to_string(auth.provider),
      name: name_from_auth(auth), avatar: avatar_from_auth(auth), email: email_from_auth(auth), nickname: nickname_from_auth(auth),
      language_id: language_from_auth(auth), role: test_email(email_from_auth(auth))}
  end

  defp test_email(email) do
    if email == System.get_env("SUPER_EMAIL"), do: "SUPER", else: "MEMBER"
  end

  defp token_from_auth(%{credentials: %{token: token}}), do: token
  defp exp_token_from_auth(%{credentials: %{expires_at: exp}}) do
    # Google announces seconds
    Timex.shift(Timex.now, seconds: exp)
  end

  defp email_from_auth(%{info: %{email: email}}), do: email
  defp language_from_auth(%{extra: %{raw_info: %{user: %{"locale" => locale}}}}) do
    case get_language_by_code(locale) do
      nil -> get_language_by_code("en").id
      response -> response.id
    end
   end

  # github does it this way
  # defp avatar_from_auth( %{info: %{urls: %{avatar_url: image}} }), do: image
  #facebook & google does it this way
  defp avatar_from_auth( %{info: %{image: image} }), do: image
  # default case if nothing matches
  defp avatar_from_auth( auth ) do
    Logger.warn auth.provider <> " needs to find an avatar URL!"
    Logger.debug(Poison.encode!(auth))
    nil
  end

  defp nickname_from_auth(auth) do
    if %{info: %{nickname: nickname}} = auth do
      case nickname do
        nil -> build_nickname(auth)
        _ -> nickname
      end
    else
      build_nickname(auth)
    end
  end

  defp build_nickname(auth) do
    if %{info: %{first_name: first_name}} = auth do
      first_name
    else
      name_from_auth(auth)
    end
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name = [auth.info.first_name, auth.info.last_name]
      |> Enum.filter(&(&1 != nil and &1 != ""))

      cond do
        length(name) == 0 -> auth.info.nickname
        true -> Enum.join(name, " ")
      end
    end
  end

  # ---------------------------- USERS -------------------------------------------
  # QUERIES ------------------------------------------------------------------
  defp filter_user_learning_datas(user_id) do
    # Get cards in user Memberships having
    from cl in Classroom,
      join: mb in assoc(cl, :memberships),
      join: u in assoc(mb, :user), where: u.id == ^user_id,
      join: i in assoc(mb, :items), where: i.active == true, #
      join: c in assoc(i, :cards), on: c.item_id == i.id, where: c.active == true, # here
      left_join: mem in assoc(c, :memorys), on: mem.card_id == c.id and mem.membership_id == mb.id,
      join: lg1 in assoc(mb, :student_lg),
      join: lg2 in assoc(mb, :teacher_lg),
      join: p in assoc(mb, :pack),
      join: pl in assoc(p, :packlanguages),
      preload: [memberships: {mb, pack: {p, packlanguages: pl}, student_lg: lg1, teacher_lg: lg2, items: {i, cards: {c, memorys: mem}}}]
  end

  # from i in query,
  #   left_join: c in assoc(i, :cards),
  #   on: (c.item_id == i.id) and c.language_id == ^language_id,
  #   where: is_nil(c.id)

  defp count_membership_card_link(card_id, membership_id) do
    from mb in Membership,
      where: mb.id == ^membership_id,
      join: i in assoc(mb, :items), where: i.active == true,
      join: c in assoc(i, :cards), where: c.active == true and c.id == ^card_id,
      # select: fragment("count(?)", mb.id)
      select: count("*")
  end

  # METHODS ------------------------------------------------------------------
  def update_user_data(%{"classrooms" => classrooms, "options" => options}) do
    classrooms
      # |> IO.inspect()
      |> Enum.map(fn(classroom) -> filter_user_data_classroom(classroom, options) end)
      |> List.flatten()
      |> Enum.filter(fn(memory_map) -> check_membership_to_card_link(memory_map) end)
      |> Enum.map(fn(memory_map) -> update_user_memory(memory_map) end)
  end

  defp filter_user_data_classroom(%{"memberships" => memberships}, options) do
    memberships
      |> Enum.map(fn(membership) -> filter_user_data_membership(membership, options) end)
  end

  defp filter_user_data_membership(%{"cards" => cards, "id" => membership_id}, options) do
    cards
      |> Enum.map(fn(card) -> filter_user_data_card(card, membership_id, options) end)
  end

  defp filter_user_data_card(card, membership_id, options) do
    # We map the data ourselves since we dont want a user to modify other fields locally
    %{
      membership_id: membership_id,
      card_id: card["id"],
      status: card["status"],
      nb_practice: card["nb_practice"],
      nb_view: card["nb_view"],
      nb_downgrade: card["nb_downgrade"],
      user_alert: card["user_alert"],
      last_update: options["last_update"]
    }
  end

  defp check_membership_to_card_link(%{card_id: card_id, membership_id: membership_id}) do
    # We control that the Card is linked to a Membership and active
    # since a user can have card locally that do not exist anymore for this membership
    query = count_membership_card_link(card_id, membership_id)
      |> Repo.one()
    if query > 0, do: true, else: false
  end

  defp update_user_memory(memory_params) do
    old_memory = get_user_memory(memory_params.membership_id, memory_params.card_id)
    case old_memory do
      nil ->
        create_memory(memory_params)
      old_memory ->
        if memory_params.user_alert == true && old_memory.alert_date != nil do
          # Compare the 2 dates to check user_alert is newer
          params = control_alert_date_newer(memory_params, old_memory)
        else
          params = memory_params
        end
        changeset = Memory.changeset(old_memory, params)
        Repo.update!(changeset)
    end
  end

  defp control_alert_date_newer(memory_params, old_memory) do
    {:ok, user_date} = memory_params.last_update
      # |> IO.inspect()
      |> Timex.Parse.DateTime.Parser.parse("{ISO:Extended:Z}")
      # |> IO.inspect()
    case DateTime.compare(user_date, old_memory.alert_date) do
      :gt -> # user alert > card correction on server side
        memory_params
          # |> IO.inspect()
      _ -> # user alert < card correction on server side
        Map.delete(memory_params, :user_alert)
    end
  end

  def get_user_learning_data(user_id) do
    classrooms = user_id
      |> filter_user_learning_datas() # Get public datas from repo
      |> Repo.all() # Build the public data map
      |> Enum.map(fn(classroom) -> filter_public_data_classroom(classroom) end)
    %{classrooms: classrooms, options: %{last_update: DateTime.utc_now()}}
      |> IO.inspect()
  end

  defp filter_public_data_classroom(classroom) do
    memberships = classroom.memberships
      |> Enum.map(fn(membership) -> filter_public_data_membership(membership) end)
    %{id: classroom.id, title: classroom.title, memberships: memberships}
  end

  defp filter_public_data_membership(membership) do
    cards = membership.items
      |> Enum.map(fn(item) -> filter_public_data_item(item, membership) end)
      |> Enum.filter(fn x -> x != nil end) # Some cards are not kept (translations)
    # Find Membership title shown to user in his language
    packlanguage = membership.pack.packlanguages
      |> Enum.filter(fn packlanguage -> packlanguage.language_id == membership.student_lg_id end)
      |> List.first()
    %{
      id: membership.id, cards: cards, title: packlanguage.title,
      languages: %{
        student_lg: %{language_id: membership.student_lg.id, iso2code: membership.student_lg.iso2code, title: membership.student_lg.title},
        teacher_lg: %{language_id: membership.teacher_lg.id, iso2code: membership.teacher_lg.iso2code, title: membership.teacher_lg.title}
      }
    }
  end

  defp filter_public_data_item(item, membership) do
    # Returns an array of cards filtered
    card = get_public_data_card(item.cards, membership.teacher_lg_id)
    case card do
      nil -> data = nil # No card was found for teacher_lg_id
      card ->
        mem = get_public_data_card_memory(card, membership.id)
        translation = get_public_data_card_translation(item.cards, membership)
        case membership.mono_lg do
          true -> # Monolanguage membership : translation not used
            data = %{item_id: item.id, picture: item.picture, answer: card.answer, memory: true,
              id: card.id, question: card.question, phonetic: card.phonetic, sound: card.sound, language_id: card.language_id,
              status: mem.status, nb_practice: mem.nb_practice, nb_view: mem.nb_view, nb_downgrade: mem.nb_downgrade, user_alert: mem.user_alert, alert_date: mem.alert_date
            }
          false -> # Multilanguage membership : translation has to be used
            data =%{item_id: item.id, picture: item.picture, answer: translation, memory: true,
              id: card.id, question: card.question, phonetic: card.phonetic, sound: card.sound, language_id: card.language_id,
              status: mem.status, nb_practice: mem.nb_practice, nb_view: mem.nb_view, nb_downgrade: mem.nb_downgrade, user_alert: mem.user_alert, alert_date: mem.alert_date
            }
        end
    end
    data
  end

  defp get_public_data_card(cards, teacher_lg_id) do
    cards
      |> Enum.filter(fn c -> c.language_id == teacher_lg_id end)
      |> List.first()
  end

  defp get_public_data_card_memory(card, membership_id) do
    memory = card.memorys
      |> List.first()
    case memory do
      nil ->
        %{status: 0, nb_practice: 0, nb_view: 0, nb_downgrade: 0, user_alert: false, alert_date: nil}
      memory ->
        memory
    end
  end

  defp get_public_data_card_translation(cards, membership) do
    case membership.mono_lg do
      false ->
        card = cards
          |> Enum.filter(fn c -> c.language_id == membership.student_lg_id end)
          |> List.first()
        card.question
      true -> nil
    end
  end

  # defp filter_public_data_card(card, membership, item_id, picture, item_translations_array) do
  #   cond do
  #     card.language_id == membership.teacher_lg_id ->
  #       # This Card has to be learned : keep it and loop in Memorys list to find it (if it exists)
  #       memory = card.memorys
  #         |> Enum.map(fn(memory) -> filter_public_data_memory(memory, membership) end)
  #         |> Enum.filter(fn x -> x != nil end)
  #         # |> IO.inspect
  #       case memory do
  #         [] -> mem_map = %{status: 0, nb_practice: 0}
  #         [map] -> mem_map = map
  #       end
  #       case item_translations_array do
  #         [] -> card_answer = card.answer
  #         array -> card_answer = array |> Enum.join(", ")
  #       end
  #       %{id: card.id, item_id: item_id, question: card.question, answer: card_answer, phonetic: card.phonetic,
  #         picture: picture, sound: card.sound, language_id: card.language_id, memory: true,
  #         status: mem_map.status, nb_practice: mem_map.nb_practice
  #       }
  #     true ->
  #       IO.puts("here!")
  #       IO.inspect(card.id)
  #       # This Card is NOT to be learned (translation or cbazfazrfp Ecto query) : throw it
  #       nil
  #   end
  # end

  # defp test_card_student_language_id(card, acc, membership) do
  #   # Test if card language is student language and check that membership has 2 languages
  #   if card.language_id == membership.student_lg_id && membership.teacher_lg_id != membership.student_lg_id do
  #     acc ++ [card.question]
  #   else
  #     acc
  #   end
  # end

  # defp filter_public_data_memory(memory, membership) do
  #   cond do
  #     memory.membership_id == membership.id ->
  #       %{status: memory.status, nb_practice: memory.nb_practice}
  #     true ->
  #       nil
  #   end
  # end

  def list_users do
    Repo.all(User)
      |> Repo.preload(:language)
  end

  def admin_user? (user) do
    if Enum.member?(["ADMIN", "SUPER"], user.role) do
      true
    else
      false
    end
  end

  def super_user? (user) do
    if Enum.member?(["SUPER"], user.role) do
      true
    else
      false
    end
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  # -------------------------------- MEMBERSHIPS ----------------------------------------
  # QUERIES ------------------------------------------------------------------
  defp query_membership_cards (query \\ Membership) do
    query
      |> join(:left, [..., membership], _ in assoc(membership, :items))
      |> where([..., item], item.active == true)
      |> join(:left, [..., item], _ in assoc(item, :cards))
      |> where([..., card], card.active == true)
      |> where([..., membership, item, card], card.language_id in [membership.teacher_lg_id, membership.student_lg_id])
      |> preload([..., item, card], [items: {item, cards: card}])
  end

  defp filter_memberships_by_languages(query \\ Membership, pack_id, user_id, query_languages) do
    from m in query,
    where: m.pack_id == ^pack_id and m.user_id == ^user_id and m.teacher_lg_id in ^query_languages and m.student_lg_id in ^query_languages
  end

  def filter_memberships_for_user_query(student_lg_id, teacher_lg_id, user_id) do
    from mb in Membership,
      where: mb.student_lg_id in [^student_lg_id, ^teacher_lg_id],
      where: mb.teacher_lg_id in [^student_lg_id, ^teacher_lg_id],
      where: mb.user_id == ^user_id
  end

  # MEMBERSHIPS METHODS ------------------------------------------------------------------
  def toogle_membership(user_id, student_lg_id, teacher_lg_id, pack_id) do
    case get_membership(user_id, pack_id, student_lg_id, teacher_lg_id) do
      %Membership{} = membership ->
        # There is allready a Membership : delete it (and delete the memories)
        case delete_membership(membership) do
          {:ok, membership} -> {:deleted, "membership #{membership.id} was deleted with all his cards"}
          {:error, reason} -> {:error, reason}
        end
      nil ->
        # There wasnt any Membership : create it
        case create_membership(%{user_id: user_id, pack_id: pack_id, student_lg_id: student_lg_id, teacher_lg_id: teacher_lg_id}) do
          {:ok, membership} -> {:created, "membership #{membership.id} was created"}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  def list_memberships(params) do
    {rummage_query, rummage} = QueryFilter.build_rummage_query(params, Membership)
    memberships = rummage_query
      |> Repo.all()
      |> Repo.preload([:user, :student_lg, :teacher_lg, pack: [:classroom]])
    {memberships, rummage}
  end

  def get_membership!(id), do: Repo.get!(Membership, id)

  def get_membership(user_id, pack_id, student_lg_id, teacher_lg_id) do
    query_languages = [student_lg_id, teacher_lg_id]
    Membership
      |> filter_memberships_by_languages(pack_id, user_id, query_languages)
      |> Repo.one()
  end

  def create_membership(attrs \\ %{}) do
    %Membership{}
      |> Membership.changeset(attrs)
      |> Repo.insert()
  end

  def update_membership(%Membership{} = membership, attrs) do
    membership
      |> Membership.changeset(attrs)
      |> Repo.update()
  end

  def delete_membership(%Membership{} = membership) do
    Repo.delete(membership)
  end

  def change_membership(%Membership{} = membership) do
    Membership.changeset(membership, %{})
  end

  # -------------------------------- MEMORYS ----------------------------------------
  # QUERIES ------------------------------------------------------------------
  defp filter_memorys_by_card_and_membership(query \\ Memory, membership_id, card_id) do
    from m in query,
      where: m.membership_id == ^membership_id and m.card_id == ^card_id
  end

  def filter_memorys_with_alert(query \\ Memory) do
    from m in query,
      where: m.user_alert == true
  end

  defp filter_memorys_by_card(query \\ Memory, card_id) do
    from mem in query,
      where: mem.card_id == ^card_id
  end

  # METHODS ------------------------------------------------------------------
  def list_memorys do
    Memory
      |> Repo.all()
      |> Repo.preload([:card, membership: [:user, :pack, :student_lg, :teacher_lg]])
  end

  def get_memory!(id), do: Repo.get!(Memory, id)

  def get_user_memory(membership_id, card_id) do
    Memory
      |> filter_memorys_by_card_and_membership(membership_id, card_id)
      |> Repo.one()
  end

  def create_memory(attrs \\ %{}) do
    %Memory{}
      |> Memory.changeset(attrs)
      |> Repo.insert()
  end

  def update_memory(%Memory{} = memory, attrs) do
    memory
      |> Memory.changeset(attrs)
      |> Repo.update()
  end

  def delete_memory_alert_for_card_id(card_id) do
    memorys = Memory
      |> filter_memorys_by_card(card_id)
      |> Repo.all()
      |> Enum.filter(fn(mem) -> mem.user_alert == true end)
      |> Enum.map(fn(mem) -> remove_alert_for_memory(mem) end)
  end

  defp remove_alert_for_memory(memory) do
    memory
      |> Memory.changeset(%{user_alert: false, alert_date: DateTime.utc_now()})
      |> Repo.update()
  end

  def delete_memory(%Memory{} = memory) do
    Repo.delete(memory)
  end

  def change_memory(%Memory{} = memory) do
    Memory.changeset(memory, %{})
  end

  # -------------------------------- LANGUAGES ----------------------------------------
  # QUERIES ------------------------------------------------------------------
    defp select_languages_for_dropdown do
      from l in Language,
        select: {l.title, l.id}
    end

    defp filter_possible_languages_for_item_new_card(item_id) do
      from l in Language,
        left_join: c in assoc(l, :cards), on: c.item_id == ^item_id and c.language_id == l.id,
        where: is_nil(c.id),
        select: {l.title, l.id}
    end

  # METHODS ------------------------------------------------------------------
  def languages_select_btn do
    select_languages_for_dropdown
      |> Repo.all()
  end

  def possible_languages_select_btn(item_id) do
    filter_possible_languages_for_item_new_card(item_id)
      |> Repo.all()
  end

  def choose_random_language do
    Language
      |> Repo.all()
      |> Enum.random()
  end

  def list_languages do
    Repo.all(Language)
  end

  def list_pack_languages(pack_id) do
    query1 = Contents.preload_language_packlanguages_filtered_by_pack_id(pack_id)
    query2 = Contents.preload_language_cards_filtered_by_pack_id(pack_id)
    Language
      |> Repo.all()
      |> Repo.preload([packlanguages: query1, cards: query2])
  end

  def get_language!(id), do: Repo.get!(Language, id)

  def get_language_by_code(iso2code) do
    Language
      |> Repo.get_by(iso2code: String.downcase(iso2code))
  end

  def create_language(attrs \\ %{}) do
    %Language{}
      |> Language.changeset(attrs)
      |> Repo.insert()
  end

  def update_language(%Language{} = language, attrs) do
    language
      |> Language.changeset(attrs)
      |> Repo.update()
  end

  def delete_language(%Language{} = language) do
    Repo.delete(language)
  end

  def change_language(%Language{} = language) do
    Language.changeset(language, %{})
  end
end

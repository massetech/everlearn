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
    from cl in Classroom,
      join: mb in assoc(cl, :memberships),
      join: u in assoc(mb, :user), where: u.id == ^user_id,
      join: i in assoc(mb, :items), where: i.active == true,
      join: c in assoc(i, :cards), where: c.active == true,
      left_join: mem in assoc(c, :memorys),
      join: lg1 in assoc(mb, :student_lg),
      join: lg2 in assoc(mb, :teacher_lg),
      join: p in assoc(mb, :pack),
      join: pl in assoc(p, :packlanguages),
      preload: [memberships: {mb, pack: {p, packlanguages: pl}, student_lg: lg1, teacher_lg: lg2, items: {i, cards: {c, memorys: mem}}}]
  end

  defp count_membership_card_link(card_id, membership_id) do
    from mb in Membership,
      where: mb.id == ^membership_id,
      join: i in assoc(mb, :items), where: i.active == true,
      join: c in assoc(i, :cards), where: c.active == true and c.id == ^card_id,
      # select: fragment("count(?)", mb.id)
      select: count("*")
  end

  # METHODS ------------------------------------------------------------------
  def update_user_data(classroom_array) do
    classroom_array
      |> Enum.map(fn(classroom) -> filter_user_data_classroom(classroom) end)
      |> List.flatten()
      |> Enum.filter(fn(memory_map) -> check_membership_to_card_link(memory_map) end)
      |> Enum.map(fn(memory_map) -> update_user_memory(memory_map) end)
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
        count = old_memory.nb_practice + memory_params.nb_practice
        changeset = Memory.changeset(old_memory, %{nb_practice: count, status: memory_params.status})
        Repo.update!(changeset)
    end
  end

  defp filter_user_data_classroom(%{"memberships" => memberships}) do
    memberships
      |> Enum.map(fn(membership) -> filter_user_data_membership(membership) end)
  end

  defp filter_user_data_membership(%{"cards" => cards, "id" => membership_id}) do
    cards
      |> Enum.map(fn(card) -> filter_user_data_card(card, membership_id) end)
  end

  defp filter_user_data_card(card, membership_id) do
    %{
      membership_id: membership_id,
      card_id: card["id"],
      status: card["status"],
      nb_practice: card["nb_practice"]
    }
  end

  def get_user_learning_data(user_id) do
    classrooms = user_id
      # Get public datas from repo
      |> filter_user_learning_datas()
      |> Repo.all()
      # Build the public data map
      |> Enum.map(fn(classroom) -> filter_public_data_classroom(classroom) end)
    %{classrooms: classrooms, options: %{}}
  end

  defp filter_public_data_classroom(classroom) do
    # Loop in Classrooms list
    memberships = classroom.memberships
      |> Enum.map(fn(membership) -> filter_public_data_membership(membership) end)
    %{id: classroom.id, title: classroom.title, memberships: memberships}
  end

  defp filter_public_data_membership(membership) do
    # Loop in Items list and return a list of cards
    # Loop in Packlanguages list to get the Membership title
    cards = membership.items
      |> Enum.map(fn(item) -> filter_public_data_item(item, membership) end)
      |> List.flatten
    membership_title = membership.pack.packlanguages
      |> Enum.map(fn(packlanguage) -> filter_public_data_packlanguage(packlanguage, membership) end)
      |> Enum.filter(fn x -> x != nil end)
      |> List.first()
    %{
      id: membership.id, cards: cards, title: membership_title,
      languages: %{
        student_lg: %{language_id: membership.student_lg.id, iso2code: membership.student_lg.iso2code, title: membership.student_lg.title},
        teacher_lg: %{language_id: membership.teacher_lg.id, iso2code: membership.teacher_lg.iso2code, title: membership.teacher_lg.title}
      }
    }
  end

  defp filter_public_data_packlanguage(packlanguage, membership) do
    # Get the Membership title in the student language
    cond do
      packlanguage.language_id == membership.student_lg_id -> packlanguage.title
      true -> nil
    end
  end

  defp filter_public_data_item(item, membership) do
    # Loop in Cards list and return a Item map
    item_translations_array = item.cards
      # Load Item translations in array
      |> Enum.reduce([], fn(card, acc) -> test_card_student_language_id(card, acc, membership) end)
    picture = item.picture
    item_id = item.id
    cards = item.cards
      |> Enum.map(fn(card) -> filter_public_data_card(card, membership, item_id, picture, item_translations_array) end)
      |> Enum.filter(fn x -> x != nil end)
    cards
  end

  defp test_card_student_language_id(card, acc, membership) do
    # Test if card language is student language and check that membership has 2 languages
    if card.language_id == membership.student_lg_id && membership.teacher_lg_id != membership.student_lg_id do
      acc ++ [card.question]
    else
      acc
    end
  end

  defp filter_public_data_card(card, membership, item_id, picture, item_translations_array) do
    cond do
      card.language_id == membership.teacher_lg_id ->
        # This Card has to be learned : keep it and loop in Memorys list to find it if it exists
        memory = card.memorys
          |> Enum.map(fn(memory) -> filter_public_data_memory(memory, membership) end)
          |> Enum.filter(fn x -> x != nil end)
          # |> IO.inspect
        case memory do
          [] -> mem_map = %{status: 0, nb_practice: 0}
          [map] -> mem_map = map
        end
        case item_translations_array do
          [] -> card_answer = card.answer
          array -> card_answer = array |> Enum.join(", ")
        end
        %{id: card.id, item_id: item_id, question: card.question, answer: card_answer, phonetic: card.phonetic,
          picture: picture, sound: card.sound, language_id: card.language_id, memory: true,
          status: mem_map.status, nb_practice: mem_map.nb_practice
        }
      true ->
        # This Card is NOT to be learned (translation or cbazfazrfp Ecto query) : throw it
        nil
    end
  end

  defp filter_public_data_memory(memory, membership) do
    cond do
      memory.membership_id == membership.id ->
        %{status: memory.status, nb_practice: memory.nb_practice}
      true ->
        nil
    end
  end

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
  # MEMORYS QUERIES ------------------------------------------------------------------
  defp filter_memory_by_card_id(query \\ Memory, membership_id, card_id) do
    from m in query,
      where: m.membership_id == ^membership_id and m.card_id == ^card_id
  end

  # MEMORYS METHODS ------------------------------------------------------------------
  def list_memorys do
    Memory
      |> Repo.all()
      |> Repo.preload([:card, membership: [:user, :pack, :student_lg, :teacher_lg]])
  end

  def get_memory!(id), do: Repo.get!(Memory, id)

  def get_user_memory(membership_id, card_id) do
    Memory
      |> filter_memory_by_card_id(membership_id, card_id)
      |> Repo.one()
  end

  # def copy_cards_to_memory(pack_id, membership_id, learning_lg_id) do
  #   memorys = Contents.get_cards_for_memory(pack_id, learning_lg_id)
  #   # Build a list of maps fith card_id and membership_id
  #   # ie : [%{card_id: 109, membership_id: 1}, %{card_id: 107, membership_id: 1}]
  #   |> Enum.reduce([], fn(card, acc) -> acc ++ [%{membership_id: membership_id, card_id: card.id}] end)
  #   # Enum on this list to insert each card in the memory ; returns are set in acc
  #   # ie :
  #   # %{
  #   #   errors: [
  #   #     error: #Ecto.Changeset<
  #   #       action: :insert,
  #   #       changes: %{card_id: 109, membership_id: 1},
  #   #       errors: [membership: {"does not exist", []}],
  #   #       data: #Everlearn.Members.Memory<>,
  #   #       valid?: false
  #   #     >
  #   #   ],
  #   #   ok: []
  #   # }
  #   |> Enum.reduce(%{ok: [], errors: []}, &insert_card_to_memory/2)
  #   msg = "for pack #{pack_id} and language #{learning_lg_id} and #{Enum.count(memorys.ok)} cards were imported with #{Enum.count(memorys.errors)} errors"
  #   {:ok, msg}
  # end

  # def insert_card_to_memory(params, acc) do
  #   case create_memory(params) do
  #     {:ok, membership} ->
  #       %{ok: acc.ok ++ [{:ok, membership}], errors: acc.errors}
  #     {:error, reason} ->
  #       %{ok: acc.ok, errors: acc.errors ++ [{:error, reason}]}
  #   end
  # end

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

  # METHODS ------------------------------------------------------------------
  def languages_select_btn do
    select_languages_for_dropdown
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

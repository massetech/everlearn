defmodule Everlearn.Contents do
  import Ecto.Query, warn: false
  import Everlearn.{CustomMethods}

  alias Everlearn.Contents.{Pack, PackItem, Classroom, Item, Topic, Card, Kind, PackLanguage}
  alias Everlearn.Members.{Memory, Membership}
  alias Everlearn.{Repo, Members, QueryFilter}

# ---------------------------- PACKS -------------------------------------------
# PACKS QUERIES ------------------------------------------------------------------
  def pack_from_id(pack_id) do
    from p in Pack, where: p.id == ^pack_id
  end

# PACKS METHODS ------------------------------------------------------------------
  def pack_level_select_btn do
    [beginner: 1, advanced: 2, expert: 3]
  end

  def list_packs(params) do
    {result, rummage} = Pack
      |> Rummage.Ecto.rummage(QueryFilter.filter(params, Pack))
    pi_query = from pi in PackItem,
      join: i in assoc(pi, :item),
      where: i.active == true
    packs = result
      |> IO.inspect()
      |> order_by([pack, ...], [desc: pack.updated_at])
      |> Repo.all()
      |> Repo.preload([:classroom, [packlanguages: :language, packitems: pi_query]])
    {packs, rummage}
  end

  def list_public_packs(params, user_id) do
    student_lg_id = params["search"]["student_lg_id"]
    teacher_lg_id = params["search"]["teacher_lg_id"]
    {result, rummage} = Pack
      |> Rummage.Ecto.rummage(QueryFilter.filter(params, Pack))
    query1 = from pl in PackLanguage,
      # A voir si encore besoin de ça
      join: l in assoc(pl, :language),
      where: l.id == ^student_lg_id,
      preload: [:language]
    query2 = from i in Item,
      where: i.active == true,
      # Add clause : having at least one active card in [^student_lg_id, ^teacher_lg_id]
      # join: c in assoc(i, :card),
      # where: c.active == true,
      # where: c.language_id in [^student_lg_id, ^teacher_lg_id],
      select: i
    query3 = from mb in Membership,
      # Preload the memberships existing in languages parameters
      where: mb.student_lg_id in [^student_lg_id, ^teacher_lg_id],
      where: mb.teacher_lg_id in [^student_lg_id, ^teacher_lg_id],
      where: mb.user_id == ^user_id
    packs = result
      |> IO.inspect()
      |> filter_language(student_lg_id, teacher_lg_id)
      |> filter_classroom(student_lg_id, teacher_lg_id)
      |> order_by([pack, ...], pack.title)
      |> where([pack, ...], pack.active == true)
      |> Repo.all()
      |> Repo.preload([memberships: query3, packlanguages: query1, items: query2])
      |> IO.inspect()
    {packs, rummage}
  end

  defp filter_language(query, student_lg_id, teacher_lg_id) do
    # On cherche tous les Packs ayant un PackLanguage == student_lg_id ET teacher_lg_id
    filtered_query = from p in query,
      join: pl1 in assoc(p, :packlanguages),
      join: pl2 in assoc(p, :packlanguages),
      where: pl1.language_id == ^student_lg_id and pl2.language_id == ^teacher_lg_id
  end

  defp filter_classroom(query, student_lg_id, teacher_lg_id) do
    # On filtre les Classrooms en fonction des langues souhaitées
    if student_lg_id == teacher_lg_id do
      filtered_query = from p in query,
        join: cl in assoc(p, :classroom),
        where: cl.mono_language == true
    else
      filtered_query = from p in query,
        join: cl in assoc(p, :classroom),
        where: cl.mono_language == false
    end
  end

  def get_pack!(id) do
    query = from i in Item,
      where: i.active == true
    Pack
    |> Repo.get!(id)
    |> Repo.preload([:classroom, items: query])
  end

  def create_pack(attrs \\ %{}) do
    %Pack{}
    |> Pack.changeset(attrs)
    |> Repo.insert()
  end

  def update_pack(%Pack{} = pack, attrs) do
    pack
    |> Pack.changeset(attrs)
    |> Repo.update()
  end

  def delete_pack(%Pack{} = pack) do
    Repo.delete(pack)
  end

  def change_pack(%Pack{} = pack) do
    Pack.changeset(pack, %{})
  end

# ------------------------ CLASSROOMS ------------------------------------------------

  def classroom_select_btn do
    Repo.all(from(c in Classroom, select: {c.title, c.id}))
  end

  def list_classrooms do
    item_query = from i in Item,
      where: i.active == true
    pack_query = from p in Pack,
      where: p.active == true
    Repo.all(Classroom)
    |> Repo.preload([[items: item_query], [packs: pack_query]])
  end

  def get_classroom!(id), do: Repo.get!(Classroom, id)

  def create_classroom(attrs \\ %{}) do
    %Classroom{}
    |> Classroom.changeset(attrs)
    |> Repo.insert()
  end

  def update_classroom(%Classroom{} = classroom, attrs) do
    classroom
    |> Classroom.changeset(attrs)
    |> Repo.update()
  end

  def delete_classroom(%Classroom{} = classroom) do
    Repo.delete(classroom)
  end

  def change_classroom(%Classroom{} = classroom) do
    Classroom.changeset(classroom, %{})
  end

# --------------------- ITEMS ----------------------------------------------------

  def control_item_fields(item_level) do
    convert_integer(item_level)
  end

  def save_item_line(fields) do
    case get_kind_by_name(fields.kind) do
      nil -> # Kind was not found
        {:error, "Kind #{fields.kind} not found"}
      kind -> # Kind was found : save item with kind_id and topic_id
        params = fields
        |> Map.put(:kind_id, kind.id)
        |> Map.delete(:kind) # Add kind_id instead of kind
        |> IO.inspect()
        case create_item(params) do
          {:ok, item} -> {:ok, "Line for item #{item.title} was processed"}
          {:error, msg} -> {:error, msg.errors}
        end
    end
  end

  def create_item(attrs \\ %{}) do
    %Item{}
      |> Item.changeset(attrs)
      |> Repo.insert()
  end

  def list_items(params) do
    {result, rummage} = Item
      |> Rummage.Ecto.rummage(QueryFilter.filter(params, Item))
    pack_query = from p in Pack,
      where: p.active == true
    card_query = from c in Card,
      where: c.active == true
    items = result
      |> order_by([item, ...], [desc: item.updated_at])
      # |> filter_classroom(params["search"]["classroom"])
      |> Repo.all()
      |> Repo.preload([:kind, :topic, :classroom, [cards: card_query], [packs: pack_query]])
    {items, rummage}
  end

  # defp filter_classroom(query \\ Item, filter) do
  #   case filter do
  #     "" -> query
  #     nil -> query
  #     _ ->
  #       classroom = get_classroom!(filter)
  #       filtered_query = from i in query,
  #         where: i.classroom_id == ^classroom.id
  #   end
  # end

  @doc """
  Imports `(params)`, finds pack from params[id], filters with rummage then lists the active items eligible to this pack depending
  on the pack classroom. Items are ordered by title ASC
  Returns an `{pack, items, rummage}` tupple with the list of items.

  ## Examples

  """
  def list_items_eligible_to_pack(params \\ %{}) do
    pack = get_pack!(params["id"])
    |> Repo.preload(:classroom)
    packitem_filter = params["search"]["packitemlink"]
    {result, rummage} = Item
    |> Rummage.Ecto.rummage(QueryFilter.filter(params, Item))
    pi_query = from pi in PackItem, where: pi.pack_id == ^pack.id
    items = result
    |> filter_packitemlink(pack, packitem_filter)
    |> filter_items_eligible_for_pack(pack)
    |> Repo.all()
    |> Repo.preload([:topic, :kind, packitems: pi_query])
    {pack, items, rummage}
  end

  defp filter_packitemlink(query, pack, filter) do
    case filter do
      "true" ->
        filtered_query = from i in query,
          join: pi in assoc(i, :packitems),
          where: pi.pack_id == ^pack.id
      "false" ->
        filtered_query = from i in query,
          left_join: pi in assoc(i, :packitems),
          where: is_nil(pi.id)
      _ -> query
    end
  end

  defp filter_items_eligible_for_pack(query, pack) do
    classroom_id = get_pack!(pack.id).classroom.id
    query
      |> join(:inner, [item, ...], _ in assoc(item, :classroom))
      # |> join(:inner, [..., topic], _ in assoc(topic, :classroom))
      |> where([item, ...], item.active == true)
      |> where([..., classroom], classroom.id == ^classroom_id)
      |> order_by([item, ...], item.title)
  end

  # def items_from_pack(query \\ Pack) do
  #   query
  #     |> join(:inner, [pack], _ in assoc(pack, :packitems))
  #     |> join(:inner, [_, packitems], _ in assoc(packitems, :item))
  #     |> select([_, _, item], item)
  # end

  def items_active(query \\ Item) do
    query
      |> where([..., item], item.active == true)
  end

  # Get all items possible for a pack
  def get_items_possible_for_pack(pack_id) do
    Item
      |> join(:inner, [item], _ in assoc(item, :topic))
      |> where([item], item.active == true)
      |> join(:inner, [_, topic], _ in assoc(topic, :classroom))
      # On filtre sur la classroom du pack recherché
      |> join(:inner, [_, _, classroom], _ in assoc(classroom, :packs))
      |> where([_, _, _, pack], pack.id == ^pack_id)
      # On ajoute les packitems si existants
      |> join(:left, [item, _, _, _], _ in assoc(item, :packitems))
      |> preload([_, _, _, _, pi], [:topic, :cards, packitems: pi])
      |> Repo.all()
  end

  defp preload_items_linked_to_each_pack(query) do
    query
      |> join(:left, [pack], _ in assoc(pack, :packitems))
      |> join(:inner, [pi], _ in assoc(pi, :items))
      # |> where([_, _, items], items.active == true)
      |> preload([_, _, items], [items: items])
  end

  # defp preload_items_not_linked_to_pack(query \\ Item) do
  #   query
  #     |> join(:left, [pack], _ in assoc(pack, :packitems))
  #     |> join(:inner, [pi], _ in assoc(pi, :items))
  #     |> where([_, _, items], items.active == true)
  #     |> select([p, c], {p, c})
  # end

  def choose_random_item(pack) do
    get_items_possible_for_pack(pack.id)
      |> Enum.random()
  end

  def get_item!(id) do
    Repo.get!(Item, id)
      |> Repo.preload(cards: [:language])
  end

  def get_item(id), do: Repo.get(Item, id)

  def item_with_title(query, title) do
    query
    |> where([u], u.title == ^title)
  end

  def item_with_level(query, level) do
    query
    |> where([u], u.level == ^level)
  end

  def get_item_by_title_and_level(title, level) do
    Item
      |> item_with_title(title)
      |> item_with_level(level)
      |> Repo.one
  end

  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  def change_item(%Item{} = item) do
    Item.changeset(item, %{})
  end

# -------------------------------- TOPICS ------------------------------------------

  def topic_select_btn do
    Repo.all(from(c in Topic, select: {c.title, c.id}))
  end

  def list_topics do
    item_query = from i in Item,
      where: i.active == true
    Topic
    |> Repo.all()
    |> Repo.preload([items: item_query])
  end

  def get_topic!(id), do: Repo.get!(Topic, id)

  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  def change_topic(%Topic{} = topic) do
    Topic.changeset(topic, %{})
  end

  # --------------------------- CARDS ----------------------------------------------
  # CARDS QUERIES ------------------------------------------------------------------
  def cards_active(query \\ Card) do
    query
      |> where([..., card], card.active == true)
  end

  def cards_from_pack(query \\ Pack) do
    query
      |> join(:inner, [p, ...], _ in assoc(p, :packitems))
      |> join(:inner, [..., pi], _ in assoc(pi, :item))
      |> join(:inner, [..., i], _ in assoc(i, :cards))
      |> select([..., card], card)
  end

  def cards_with_language(query \\ Card, language_id) do
    query
      |> where([..., card], card.language_id == ^language_id)
  end

  # CARDS METHODS ------------------------------------------------------------------
  def get_cards_for_memory(pack_id, language_id) do
    pack_from_id(pack_id)
      |> cards_from_pack()
      |> cards_active()
      |> cards_with_language(language_id)
      |> Repo.all()
  end

  def save_card_line(fields) do
    case get_item_by_title_and_level(fields.item_title, fields.item_level) do
      nil -> # Item was not found
        {:error, "Item #{fields.item_title} couldn't be found"}
      item -> # Item was found
        case Members.get_language_by_code(fields.language) do
          nil -> # Language was not found
            {:error, "Language #{fields.language} couldn't be found"}
          language -> # Language was found
            params = fields
              |> IO.inspect()
              |> Map.put(:item_id, item.id)
              |> Map.put(:language_id, language.id)
              |> Map.drop([:item, :language]) # Remove from params
            case create_card(params) do
              {:ok, _card} -> {:ok, "Line for card #{item.title} was processed"}
              {_, msg} -> {:error, msg.errors}
            end
        end
    end
  end

  def list_cards(params) do
    {result, rummage} = Card
      |> Rummage.Ecto.rummage(QueryFilter.filter(params, Card))
    cards = result
      |> Repo.all()
      |> Repo.preload([:language, [item: [:packitems]]])
    {cards, rummage}
  end

  def get_cards_from_item(item) do
    from(c in Card, where: c.item_id == ^item.id)
      |> Repo.all()
      |> Repo.preload([:language])
  end

  # def list_cards(params) do
  #   # query1 = from pi in PackItem,
  #   #   join: pack in assoc(pi, :pack),
  #   #   where: pack.active == true
  #   # query = PackItem
  #   #   |> where([u], u.active == true)
  #   Card
  #   |> Repo.all()
  #   |> Repo.preload([:language, [item: [:packitems]]])
  # end

  def get_card!(id), do: Repo.get!(Card, id)

  def create_card(attrs \\ %{}) do
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert()
  end

  def update_card(%Card{} = card, attrs) do
    card
    |> Card.changeset(attrs)
    |> Repo.update()
  end

  def delete_card(%Card{} = card) do
    Repo.delete(card)
  end

  def change_card(%Card{} = card) do
    Card.changeset(card, %{})
  end

  # ------------------------- PACKITEMS ----------------------------------------------

  # def generate_pack_items(pack) do
  #   pack
  #   |> choose_random_item()
  #   |> Ecto.build_assoc(:packitems, %{pack_id: pack.id})
  #   |> Repo.insert!()
  # end

  def toogle_pack_item(item_id, pack_id) do
    case get_pack_item(item_id, pack_id) do
      %PackItem{} = pack_item ->
        # There is allready a PackItem : delete it
        case delete_pack_item(pack_item) do
          {:ok, pack_item} -> {:deleted, pack_item}
          {:error, reason} -> {:error, reason}
        end
      nil ->
        # There wasnt any PackItem : create it
        case create_pack_item(%{item_id: item_id, pack_id: pack_id}) do
          {:ok, pack_item} -> {:created, pack_item}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  def get_pack_item(item_id, pack_id) do
    query = from p in PackItem,
      where: p.item_id == ^item_id and p.pack_id == ^pack_id,
      select: p
    Repo.one(query)
  end

  def list_pack_items(pack_id) do
    query = from p in PackItem, where: p.pack_id == ^pack_id
    Repo.all(query)
  end

  def create_pack_item(attrs \\ %{}) do
    %PackItem{}
    |> PackItem.changeset(attrs)
    |> Repo.insert()
  end

  def delete_pack_item(%PackItem{} = pack_item) do
    Repo.delete(pack_item)
  end

  def clean_existing_packitems(item) do
    case item.active do
      false -> delete_pack_items(item.id)
      true -> nil
    end
  end

  defp delete_pack_items(item_id) do
    query = from p in PackItem, where: p.item_id == ^item_id
    Repo.delete_all(query)
  end

  # def change_pack_item(%PackItem{} = pack_item) do
  #   PackItem.changeset(pack_item, %{})
  # end


  # ------------------------- KINDS ----------------------------------------------

  def kind_select_btn do
    Repo.all(from(c in Kind, select: {c.title, c.id}))
  end

  def get_kind_by_name(title) do
    Kind
    |> Repo.get_by(name: title)
  end

  @doc """
  Returns the list of kinds.

  ## Examples

      iex> list_kinds()
      [%Kind{}, ...]

  """
  def list_kinds do
    Repo.all(Kind)
  end

  @doc """
  Gets a single kind.

  Raises `Ecto.NoResultsError` if the Kind does not exist.

  ## Examples

      iex> get_kind!(123)
      %Kind{}

      iex> get_kind!(456)
      ** (Ecto.NoResultsError)

  """
  def get_kind!(id), do: Repo.get!(Kind, id)

  @doc """
  Creates a kind.

  ## Examples

      iex> create_kind(%{field: value})
      {:ok, %Kind{}}

      iex> create_kind(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_kind(attrs \\ %{}) do
    %Kind{}
    |> Kind.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a kind.

  ## Examples

      iex> update_kind(kind, %{field: new_value})
      {:ok, %Kind{}}

      iex> update_kind(kind, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_kind(%Kind{} = kind, attrs) do
    kind
    |> Kind.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Kind.

  ## Examples

      iex> delete_kind(kind)
      {:ok, %Kind{}}

      iex> delete_kind(kind)
      {:error, %Ecto.Changeset{}}

  """
  def delete_kind(%Kind{} = kind) do
    Repo.delete(kind)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking kind changes.

  ## Examples

      iex> change_kind(kind)
      %Ecto.Changeset{source: %Kind{}}

  """
  def change_kind(%Kind{} = kind) do
    Kind.changeset(kind, %{})
  end

  # ------------------------- PACKLANGUAGES ----------------------------------------------

  @doc """
  Returns the list of packlanguages.

  ## Examples

      iex> list_packlanguages()
      [%PackLanguage{}, ...]

  """
  def list_packlanguages do
    Repo.all(PackLanguage)
  end

  def count_items_for_packlanguages(pack_id, language_id) do
    query = from pl in PackLanguage,
      where: pl.language_id == ^language_id and pl.pack_id == ^pack_id,
      join: p in assoc(pl, :pack),
      join: i in assoc(p, :items),
      where: i.active == true,
      select: count("*")
    Repo.one(query)
  end

  def count_cards_for_packlanguages(pack_id, language_id) do
    query = from pl in PackLanguage,
      where: pl.language_id == ^language_id and pl.pack_id == ^pack_id,
      join: p in assoc(pl, :pack),
      join: i in assoc(p, :items),
      join: c in assoc(i, :cards),
      where: i.active == true,
      where: c.active == true,
      select: count("*")
    Repo.one(query)
  end

  @doc """
  Gets a single packlanguage.

  Raises `Ecto.NoResultsError` if the PackLanguage does not exist.

  ## Examples

      iex> get_packlanguage!(123)
      %PackLanguage{}

      iex> get_packlanguage!(456)
      ** (Ecto.NoResultsError)

  """
  def get_packlanguage!(id), do: Repo.get!(PackLanguage, id)

  @doc """
  Creates a packlanguage.

  ## Examples

      iex> create_packlanguage(%{field: value})
      {:ok, %PackLanguage{}}

      iex> create_packlanguage(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_packlanguage(attrs \\ %{}) do
    %PackLanguage{}
    |> PackLanguage.changeset(attrs)
    |> Repo.insert()
  end

  def toogle_packlanguage(language_id, pack_id, title) do
    case get_packlanguage(language_id, pack_id) do
      %PackLanguage{} = packlanguage ->
        # There is allready a PackLanguage : delete it
        case delete_packlanguage(packlanguage) do
          {:ok, packlanguage} -> {:deleted, packlanguage}
          {:error, changeset} -> {:error, changeset}
        end
      nil ->
        # There wasnt any PackLanguage : create it
        case create_packlanguage(%{language_id: language_id, pack_id: pack_id, title: title}) do
          {:ok, packlanguage} -> {:created, packlanguage}
          {:error, changeset} -> {:error, changeset}
        end
    end
  end

  defp get_packlanguage(language_id, pack_id) do
    query = from pl in PackLanguage,
      where: pl.language_id == ^language_id and pl.pack_id == ^pack_id
      # select: p
    Repo.one(query)
  end

  @doc """
  Updates a packlanguage.

  ## Examples

      iex> update_packlanguage(packlanguage, %{field: new_value})
      {:ok, %PackLanguage{}}

      iex> update_packlanguage(packlanguage, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_packlanguage(%PackLanguage{} = packlanguage, attrs) do
    packlanguage
    |> PackLanguage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PackLanguage.

  ## Examples

      iex> delete_packlanguage(packlanguage)
      {:ok, %PackLanguage{}}

      iex> delete_packlanguage(packlanguage)
      {:error, %Ecto.Changeset{}}

  """
  def delete_packlanguage(%PackLanguage{} = packlanguage) do
    Repo.delete(packlanguage)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking packlanguage changes.

  ## Examples

      iex> change_packlanguage(packlanguage)
      %Ecto.Changeset{source: %PackLanguage{}}

  """
  def change_packlanguage(%PackLanguage{} = packlanguage) do
    PackLanguage.changeset(packlanguage, %{})
  end
end

defmodule Everlearn.Contents do
  import Ecto.Query, warn: false
  import Everlearn.{CustomMethods}

  alias Everlearn.Contents.{Pack, PackItem, Classroom, Item, Topic, Card, Kind, PackLanguage}
  alias Everlearn.Members.{Memory, Membership}
  alias Everlearn.{Repo, Members, QueryFilter}

# ---------------------------- PACKS -------------------------------------------
# QUERIES ------------------------------------------------------------------
  defp select_pack_by_id(pack_id) do
    from p in Pack, where: p.id == ^pack_id
  end

  defp filter_packs_active(query \\ Pack) do
    from p in Pack,
      where: p.active == true
  end

  defp filter_packs_by_active_language(query \\ Pack, student_lg_id, teacher_lg_id) do
    # On cherche tous les Packs ayant un PackLanguage == student_lg_id ET teacher_lg_id
    filtered_query = from p in query,
      join: pl1 in assoc(p, :packlanguages),
      join: pl2 in assoc(p, :packlanguages),
      where: pl1.language_id == ^student_lg_id and pl2.language_id == ^teacher_lg_id
  end

  defp filter_packs_by_monolanguage_classroom(query \\ Pack, monolanguage) do
    # On filtre les Classrooms en fonction des langues souhaitées
    if monolanguage == true do
      filtered_query = from p in query,
        join: cl in assoc(p, :classroom),
        where: cl.mono_language == true
    else
      filtered_query = from p in query,
        join: cl in assoc(p, :classroom),
        where: cl.mono_language == false
    end
  end

# METHODS ------------------------------------------------------------------
  def pack_level_select_btn do
    [beginner: 1, advanced: 2, expert: 3]
  end

  def list_packs(params) do
    {rummage_query, rummage} = QueryFilter.build_rummage_query(params, Pack)
    pi_query = filter_packitems_active()
    packs = rummage_query
      |> order_by([pack, ...], [desc: pack.updated_at])
      |> Repo.all()
      |> Repo.preload([:classroom, [packlanguages: :language, packitems: pi_query]])
    {packs, rummage}
  end

  def list_public_packs(params, user_id) do
    student_lg_id = params["search"]["student_lg_id"]
    teacher_lg_id = params["search"]["teacher_lg_id"]
    if student_lg_id == teacher_lg_id, do: monolanguage = true, else: monolanguage = false
    {rummage_query, rummage} = QueryFilter.build_rummage_query(params, Pack)
    query1 = from pl in PackLanguage,
      # A voir si encore besoin de ça
      join: l in assoc(pl, :language),
      where: l.id == ^student_lg_id,
      preload: [:language]
    query2 = filter_items_active()
    query3 = Members.filter_memberships_for_user_query(student_lg_id, teacher_lg_id, user_id)
    packs = rummage_query
      |> filter_packs_active()
      |> order_by([pack, ...], pack.title)
      |> filter_packs_by_active_language(student_lg_id, teacher_lg_id)
      |> filter_packs_by_monolanguage_classroom(monolanguage)
      |> Repo.all()
      |> Repo.preload([memberships: query3, packlanguages: query1, items: query2])
    {packs, rummage}
  end

  def get_pack!(id) do
    query = filter_items_active()
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
# QUERIES ------------------------------------------------------------------
  defp select_classrooms_for_dropdown do
    from c in Classroom,
      select: {c.title, c.id}
  end

# METHODS ------------------------------------------------------------------
  def classroom_select_btn do
    select_classrooms_for_dropdown
      |> Repo.all()
  end

  def list_classrooms do
    item_query = filter_items_active()
    pack_query = filter_packs_active()
    Classroom
      |> Repo.all()
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
# QUERIES ------------------------------------------------------------------
defp filter_items_by_title(query \\ Item, title) do
  query
    |> where([i], i.title == ^title)
end

defp filter_items_by_level(query \\ Item, level) do
  query
    |> where([i], i.level == ^level)
end

defp filter_items_active(query \\ Item) do
  from i in query,
    where: i.active == true,
    order_by: i.title
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
  from i in query,
    join: c in assoc(i, :classroom),
    where: c.id == ^classroom_id
  # query
  #   |> join(:inner, [item, ...], _ in assoc(item, :classroom))
  #   |> where([item, ...], item.active == true)
  #   |> where([..., classroom], classroom.id == ^classroom_id)
    # |> order_by([item, ...], item.title)
end

# defp preload_items_linked_to_each_pack(query) do
#   query
#     |> join(:left, [pack], _ in assoc(pack, :packitems))
#     |> join(:inner, [pi], _ in assoc(pi, :items))
#     # |> where([_, _, items], items.active == true)
#     |> preload([_, _, items], [items: items])
# end

# defp preload_items_not_linked_to_pack(query \\ Item) do
#   query
#     |> join(:left, [pack], _ in assoc(pack, :packitems))
#     |> join(:inner, [pi], _ in assoc(pi, :items))
#     |> where([_, _, items], items.active == true)
#     |> select([p, c], {p, c})
# end

# METHODS ------------------------------------------------------------------
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
    {rummage_query, rummage} = QueryFilter.build_rummage_query(params, Item)
    pack_query = filter_packs_active()
    card_query = filter_cards_active()
    items = rummage_query
      |> order_by([item, ...], [desc: item.updated_at])
      |> Repo.all()
      |> Repo.preload([:kind, :topic, :classroom, [cards: card_query], [packs: pack_query]])
    {items, rummage}
  end

  def list_items_eligible_to_pack(params \\ %{}) do
    # Add the 2 rules since can be called by show or other action
    case Map.has_key?(params, "pack_id") do
      true -> pack_id = params["pack_id"]
      false -> pack_id = params["id"]
    end
    pack = get_pack!(pack_id)
      |> Repo.preload(:classroom)
    IO.inspect(params)
    {rummage_query, rummage} = QueryFilter.build_rummage_query(params, Item)
    # Load items list to show
    packitem_filter = params["search"]["packitemlink"]
    pi_query = filter_packitems_by_pack_id(pack.id)
    items = rummage_query
      |> filter_items_active()
      |> filter_packitemlink(pack, packitem_filter)
      |> filter_items_eligible_for_pack(pack)
      |> Repo.all()
      |> Repo.preload([:topic, :kind, packitems: pi_query])
    {pack, items, rummage}
  end

  def get_items_possible_for_pack(pack_id) do
    pack_id
      |> filter_items_eligible_to_pack()
      |> Repo.all()
  end

  def choose_random_item(pack) do
    get_items_possible_for_pack(pack.id)
      |> Enum.random()
  end

  def get_item!(id) do
    Repo.get!(Item, id)
      |> Repo.preload(cards: [:language])
  end

  def import_item(params) do
    case params.id do
      nil -> create_item(params)
      _ ->
        case get_item(params.id) do
          nil -> create_item(params)
          item ->
            case params.level do
              99 -> delete_item(item)
              _ -> update_item(item, params)
            end
        end
    end
  end

  def get_item(id), do: Repo.get(Item, id)

  def get_item_by_title_and_level(title, level) do
    Item
      |> filter_items_by_title(title)
      |> filter_items_by_level(level)
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
# QUERIES ------------------------------------------------------------------
  defp select_topics_for_dropdown do
    from t in Topic,
      select: {t.title, t.id}
  end

# METHODS ------------------------------------------------------------------
  def topic_select_btn do
    select_topics_for_dropdown
      |> Repo.all()
  end

  def list_topics do
    query = filter_items_active()
    Topic
      |> Repo.all()
      |> Repo.preload([items: query])
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
  defp filter_cards_active(query \\ Card) do
    from c in Card,
      where: c.active == true
  end

  defp filter_cards_by_item(query \\ Card, item_id) do
    from c in query,
      where: c.item_id == ^item_id
  end

  def select_cards_from_pack(query \\ Pack) do
    from p in query,
      join: pi in assoc(p, :packitems),
      join: i in assoc(pi, :item),
      join: c in assoc(i, :cards),
      select: c
    # query
    #   |> join(:inner, [p, ...], _ in assoc(p, :packitems))
    #   |> join(:inner, [..., pi], _ in assoc(pi, :item))
    #   |> join(:inner, [..., i], _ in assoc(i, :cards))
    #   |> select([..., card], card)
  end

  defp filter_cards_by_language(query \\ Card, language_id) do
    from [..., c] in query,
      where: c.language_id == ^language_id
  end

  # CARDS METHODS ------------------------------------------------------------------
  def get_cards_for_memory(pack_id, language_id) do
    pack_id
      |> select_pack_by_id()
      |> select_cards_from_pack()
      |> filter_cards_by_language(language_id)
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
    {rummage_query, rummage} = QueryFilter.build_rummage_query(params, Card)
    cards = rummage_query
      |> Repo.all()
      |> Repo.preload([:language, [item: [:packitems, :topic, :kind]]])
    {cards, rummage}
  end

  def get_cards_from_item(item) do
    Card
      |> filter_cards_by_item(item.id)
      |> Repo.all()
      |> Repo.preload([:language])
  end

  def import_card(params) do
    case params.id do
      nil -> create_card(params)
      _ ->
        case get_card(params.id) do
          nil -> create_card(params)
          card ->
            case params.phonetic do
              99 -> delete_card(card)
              _ -> update_card(card, params)
            end
        end
    end
  end

  def get_card!(id), do: Repo.get!(Card, id)
  def get_card(id), do: Repo.get(Card, id)

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
  # QUERIES ------------------------------------------------------------------
  defp filter_packitems_active(query \\ PackItem) do
    from pi in query,
      join: i in assoc(pi, :item),
      where: i.active == true
  end

  defp filter_packitems_by_pack_id(query \\ PackItem, pack_id) do
    from pi in query,
      where: pi.pack_id == ^pack_id
  end

  defp filter_packitems_by_item_id(query \\ PackItem, item_id) do
    from pi in query,
      where: pi.item_id == ^item_id
  end

  defp filter_items_eligible_to_pack(query \\ Item, pack_id) do
    query
      |> join(:inner, [item], _ in assoc(item, :topic))
      |> join(:inner, [_, topic], _ in assoc(topic, :classroom))
      |> join(:inner, [_, _, classroom], _ in assoc(classroom, :packs))
      |> where([_, _, _, pack], pack.id == ^pack_id)
      # On ajoute les packitems si existants
      |> join(:left, [item, _, _, _], _ in assoc(item, :packitems))
      |> preload([_, _, _, _, pi], [:topic, :cards, packitems: pi])
  end

  # METHODS ------------------------------------------------------------------
  def add_items_to_pack(item_list, pack_id) do
    item_list
      |> Enum.map(fn(item) -> create_packitem(%{item_id: item.id, pack_id: pack_id}) end)
  end

  def remove_items_from_pack(item_list, pack_id) do
    item_list
      |> Enum.map(fn(item) -> get_packitem(item.id, pack_id) end)
      |> Enum.map(fn(packitem) -> delete_packitem(packitem) end)
  end

  def toogle_packitem(item_id, pack_id) do
    case get_packitem(item_id, pack_id) do
      %PackItem{} = packitem ->
        # There is allready a PackItem : delete it
        case delete_packitem(packitem) do
          {:ok, packitem} -> {:deleted, packitem}
          {:error, reason} -> {:error, reason}
        end
      nil ->
        # There wasnt any PackItem : create it
        case create_packitem(%{item_id: item_id, pack_id: pack_id}) do
          {:ok, packitem} -> {:created, packitem}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  def get_packitem(item_id, pack_id) do
    PackItem
      |> filter_packitems_by_item_id(item_id)
      |> filter_packitems_by_pack_id(pack_id)
      |> Repo.one()
  end

  def list_packitems(pack_id) do
    PackItem
      |> filter_packitems_by_pack_id(pack_id)
      |> Repo.all()
  end

  def create_packitem(attrs \\ %{}) do
    %PackItem{}
      |> PackItem.changeset(attrs)
      |> Repo.insert()
  end

  def delete_packitem(%PackItem{} = packitem) do
    Repo.delete(packitem)
  end

  def clean_existing_packitems(item) do
    case item.active do
      false -> delete_packitems(item)
      true -> nil
    end
  end

  defp delete_packitems(item) do
    PackItem
      |> filter_packitems_by_item_id(item.id)
      |> Repo.delete_all()
  end

  # ------------------------- KINDS ----------------------------------------------
  # QUERIES ------------------------------------------------------------------
    defp select_kinds_for_dropdown do
      from k in Kind,
        select: {k.title, k.id}
    end

  # METHODS ------------------------------------------------------------------
  def kind_select_btn do
    select_kinds_for_dropdown
      |> Repo.all()
  end

  def get_kind_by_name(title) do
    Kind
      |> Repo.get_by(name: title)
  end

  def list_kinds do
    Repo.all(Kind)
  end

  def get_kind!(id), do: Repo.get!(Kind, id)

  def create_kind(attrs \\ %{}) do
    %Kind{}
      |> Kind.changeset(attrs)
      |> Repo.insert()
  end

  def update_kind(%Kind{} = kind, attrs) do
    kind
      |> Kind.changeset(attrs)
      |> Repo.update()
  end

  def delete_kind(%Kind{} = kind) do
    Repo.delete(kind)
  end

  def change_kind(%Kind{} = kind) do
    Kind.changeset(kind, %{})
  end

  # ------------------------- PACKLANGUAGES ----------------------------------------------
  # QUERIES ------------------------------------------------------------------
    defp select_kinds_for_dropdown do
      from k in Kind,
        select: {k.title, k.id}
    end

    def filter_packlanguages_by_pack_id(query \\ PackLanguage, pack_id) do
      from pl in query,
          where: pl.pack_id == ^pack_id
    end

    defp filter_packlanguages_by_language_id(query \\ PackLanguage, language_id) do
      from pl in query,
        where: pl.language_id == ^language_id
    end

    defp count_active_items_in_packlanguage (query \\ PackLanguage) do
      from pl in query,
        join: p in assoc(pl, :pack),
        join: i in assoc(p, :items),
        where: i.active == true,
        select: count("*")
    end

    defp count_active_cards_in_packlanguage (query \\ PackLanguage) do
      from pl in query,
      join: p in assoc(pl, :pack),
      join: i in assoc(p, :items),
      join: c in assoc(i, :cards),
      where: i.active == true,
      where: c.active == true,
      select: count("*")
  end

  # METHODS ------------------------------------------------------------------
  def list_packlanguages do
    Repo.all(PackLanguage)
  end

  def count_items_for_packlanguages(pack_id, language_id) do
    PackLanguage
      |> filter_packlanguages_by_pack_id(pack_id)
      |> filter_packlanguages_by_language_id(language_id)
      |> count_active_items_in_packlanguage
      |> Repo.one()
  end

  def count_cards_for_packlanguages(pack_id, language_id) do
    PackLanguage
      |> filter_packlanguages_by_pack_id(pack_id)
      |> filter_packlanguages_by_language_id(language_id)
      |> count_active_cards_in_packlanguage
      |> Repo.one()
  end

  def get_packlanguage!(id), do: Repo.get!(PackLanguage, id)

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
    PackLanguage
      |> filter_packlanguages_by_language_id(language_id)
      |> filter_packlanguages_by_pack_id(pack_id)
      |> Repo.one()
  end

  def update_packlanguage(%PackLanguage{} = packlanguage, attrs) do
    packlanguage
      |> PackLanguage.changeset(attrs)
      |> Repo.update()
  end

  def delete_packlanguage(%PackLanguage{} = packlanguage) do
    Repo.delete(packlanguage)
  end

  def change_packlanguage(%PackLanguage{} = packlanguage) do
    PackLanguage.changeset(packlanguage, %{})
  end

end

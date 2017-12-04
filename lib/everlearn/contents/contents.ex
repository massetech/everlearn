defmodule Everlearn.Contents do
  @moduledoc """
  The Contents context.
  """
  import Ecto.Query, warn: false
  import Everlearn.{CustomMethods}

  alias Everlearn.Contents.{Pack, PackItem, Classroom, Item, Topic, Card, Kind}
  alias Everlearn.{Repo, Members, QueryFilter}

# ---------------------------- PACKS -------------------------------------------

  def pack_level_select_btn do
    [beginner: 1, advanced: 2, expert: 3]
  end

  def list_packs(params) do
    {result, rummage} = Pack
    |> Pack.rummage(QueryFilter.filter(params, Pack))
    packs = result
      # |> preload_items_linked_to_each_pack()
      # |> preload_items_not_linked_to_pack()
      |> where([pack], pack.active == true)
      |> Repo.all()
      |> IO.inspect()
      |> Repo.preload([:classroom, :language, :memberships, :items])
    {packs, rummage}
  end

  def get_pack!(id) do
    Pack
    |> Repo.get!(id)
    |> Repo.preload([:classroom])
  end

  def pack_from_id(pack_id) do
    Pack
      |> where([pack], pack.id == ^pack_id)
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
    Repo.all(Classroom)
    |> Repo.preload([:topics, :items, :packs])
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
          {:ok, item} ->
            {:ok, "Line for item #{item.title} was processed"}
          {_, msg} ->
            {:error, msg.errors}
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
      |> Item.rummage(QueryFilter.filter(params, Item))
    items = result
      |> Repo.all()
      |> Repo.preload([topic: [:classroom]])
      |> Repo.preload([:cards, :packs, :kind])
    {items, rummage}
  end

  def items_from_pack(query \\ Pack) do
    query
      |> join(:inner, [pack], _ in assoc(pack, :packitems))
      |> join(:inner, [_, packitems], _ in assoc(packitems, :item))
      |> select([_, _, item], item)
  end

  def items_active(query \\ Item) do
    query
      |> where([..., item], item.active == true)
  end

  def get_items_from_pack(pack_id) do
    pack_from_id(pack_id)
      |> items_from_pack()
      |> items_active()
      |> Repo.all()
  end

  # Get all items possible for a pack
  def get_items_possible_for_pack(pack_id) do
    items = Item
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

  defp preload_items_linked_to_each_pack(query \\ Item) do
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

  def get_item!(id), do: Repo.get!(Item, id)

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
    Topic
    |> Repo.all()
    |> Repo.preload([:classroom, :items])
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
      |> Card.rummage(QueryFilter.filter(params, Card))
    cards = result
      |> Repo.all()
      |> Repo.preload([:language, [item: [:packitems]]])
    {cards, rummage}
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

  def generate_pack_items(pack) do
    pack
    |> choose_random_item()
    |> Ecto.build_assoc(:packitems, %{pack_id: pack.id})
    |> Repo.insert!()
  end

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

  def create_pack_item(attrs \\ %{}) do
    %PackItem{}
    |> PackItem.changeset(attrs)
    |> Repo.insert()
  end

  def delete_pack_item(%PackItem{} = pack_item) do
    Repo.delete(pack_item)
  end

  def change_pack_item(%PackItem{} = pack_item) do
    PackItem.changeset(pack_item, %{})
  end


  # ------------------------- KINDS ----------------------------------------------

  def kind_select_btn do
    Repo.all(from(c in Kind, select: {c.name, c.id}))
  end

  def get_kind_by_name(name) do
    Kind
    |> Repo.get_by(name: name)
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
end

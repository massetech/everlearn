defmodule Everlearn.Contents do
  @moduledoc """
  The Contents context.
  """

  import Ecto.Query, warn: false
  import Everlearn.{CustomMethods}
  alias Everlearn.Repo

# ------------------------- Shared functions ----------------------------------------


# ----------------------------------------------------------------------------
  alias Everlearn.Contents.Pack

  def pack_level_select_btn do
    [beginner: 1, advanced: 2, expert: 3]
  end

  def list_packs do
    Pack
    |> Repo.all()
    |> Repo.preload(:classroom)
  end

  def list_packs(query) do
    Repo.all(query)
    |> Repo.preload([:classroom]) #, packitem: [:item]
  end

  def get_pack!(id) do
    Pack
    |> Repo.get!(id)
    |> Repo.preload([:classroom])
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

# ----------------------------------------------------------------------------
  alias Everlearn.Contents.Classroom

  def classroom_select_btn do
    Repo.all(from(c in Classroom, select: {c.title, c.id}))
  end

  def list_classrooms do
    Repo.all(Classroom)
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

# ----------------------------------------------------------------------------
  alias Everlearn.Contents.Item

  def insert_item(fields, topic_id) do
    %{:item_id => item_id, :item_title => item_title, :item_level => item_level, :item_group => item_group,
      :item_active => item_active, :item_description => item_description} = fields
    cond do
      item_id == '' && item_title != "" && item_level != '' || item_group != "" ->
        # It's a new item : try to create it
        Item.changeset(%Item{}, %{
          topic_id: topic_id,
          active: convert_boolean(item_active),
          description: item_description,
          group: item_group,
          level: convert_integer(item_level),
          title: item_title
        })
        |> Repo.insert
        |> IO.inspect
      item_id != '' && (item_title != "" || item_level != '' || item_active != '' || item_description != '' || item_group != "") ->
        # It's an existing item : try to update it
        Item.changeset(%Item{}, %{
          id: item_id,
          topic_id: topic_id,
          active: convert_boolean(item_active),
          description: item_description,
          group: item_group,
          level: item_level,
          title: item_title
        })
        |> Repo.update
      item_id != "" ->
        # There is only item_id : use it to create a card
        case get_item!(item_id) do
          {:ok, _} ->
            # The item was found, we can use it to create a card
            {:ok, get_item!(item_id)}
          {_, _} ->
            # The item was not found, we cant create a card
            {:error_item, "error in fetching the item #{item_id}"}
        end
      true ->
        # Some errors were found in the line
        {:error_item, "error in inserting one item"}
    end
  end

  def list_items() do
    Item
    |> Repo.all()
    |> Repo.preload(:topic)
  end

  def list_items(pack_id) do
    # Filter on the Pack ID
    query = from p in Everlearn.Contents.PackItem, where: p.pack_id == ^pack_id
    Item
    |> Repo.all()
    |> Repo.preload(packitems: query)
  end

  def list_items(query) do
    Repo.all(query)
    |> Repo.preload([topic: [:classroom]])
  end

  def get_item!(id), do: Repo.get!(Item, id)

  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
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

# ----------------------------------------------------------------------------
  alias Everlearn.Contents.Topic

  def topic_select_btn do
    Repo.all(from(c in Topic, select: {c.title, c.id}))
  end

  def list_topics do
    Topic
    |> Repo.all()
    |> Repo.preload(:classroom)
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

  # ----------------------------------------------------------------------------
  alias Everlearn.Contents.Card

  def insert_card(line, topic_id) do
    {status, fields} = line
    case status do
      :ok ->
        case insert_item(fields, topic_id) do
          # Call function to create or update item
          {:ok, item_struct} ->
            # Item was created, updated or found : create the card with item_id
            %{:card_active => card_active, :card_language => card_language, :card_title => card_title} = fields
            Card.changeset(%Card{}, %{
              item_id: item_struct.id,
              active: convert_boolean(card_active),
              language: card_language,
              title: card_title
            })
            |> Repo.insert
          {status, msg} ->
            # Some problem occured in item process
            {status, msg}
        end
      :error ->
        %{:item_id => item_id} = fields
        IO.inspect(line)
        {:error_line, "some errors where found on item with ID = #{item_id}"}
    end
  end

  def list_cards do
    Repo.all(Card)
  end

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

  # ----------------------------------------------------------------------------
  alias Everlearn.Contents.PackItem
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
end

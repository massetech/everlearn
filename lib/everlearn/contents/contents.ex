defmodule Everlearn.Contents do
  @moduledoc """
  The Contents context.
  """

  import Ecto.Query, warn: false
  import Everlearn.{CustomMethods}
  alias Everlearn.Repo

# ----------------------------------------------------------------------------
  alias Everlearn.Contents.Pack

  def list_packs do
    Repo.all(Pack)
  end

  def get_pack!(id), do: Repo.get!(Pack, id)

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

  def insert_item(fields) do
    %{:item_id => item_id, :item_title => item_title, :item_level => item_level, :item_group => item_group,
      :item_active => item_active, :item_description => item_description} = fields
    cond do
      item_id == '' && item_title != "" && item_level != '' || item_group != "" ->
        # It's a new item : try to create it
        Item.changeset(%Item{}, %{
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

  def list_items do
    Repo.all(Item)
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
  alias Everlearn.Contents.PackItem

  def list_packitems do
    Repo.all(PackItem)
  end

  def get_pack_item!(id), do: Repo.get!(PackItem, id)

  def create_pack_item(attrs \\ %{}) do
    %PackItem{}
    |> PackItem.changeset(attrs)
    |> Repo.insert()
  end

  def update_pack_item(%PackItem{} = pack_item, attrs) do
    pack_item
    |> PackItem.changeset(attrs)
    |> Repo.update()
  end

  def delete_pack_item(%PackItem{} = pack_item) do
    Repo.delete(pack_item)
  end

  def change_pack_item(%PackItem{} = pack_item) do
    PackItem.changeset(pack_item, %{})
  end

# ----------------------------------------------------------------------------
  alias Everlearn.Contents.Topic

  def topic_select_btn do
    Repo.all(from(c in Topic, select: {c.title, c.id}))
  end

  def list_topics do
    Repo.all(Topic)
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

  def insert_card(line) do
    {status, fields} = line
    case status do
      :ok ->
        case insert_item(fields) do
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
        {:error_line, "some errors where found on line #{item_id}"}
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

end

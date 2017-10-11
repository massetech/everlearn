defmodule Everlearn.Contents do
  @moduledoc """
  The Contents context.
  """

  import Ecto.Query, warn: false
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

  def select_classroom do
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

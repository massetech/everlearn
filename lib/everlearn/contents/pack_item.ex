defmodule Everlearn.Contents.PackItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.{PackItem, Pack, Item}

  schema "packitems" do
    belongs_to :pack, Pack
    belongs_to :item, Item
    timestamps()
  end

  @doc false
  def changeset(%PackItem{} = pack_item, attrs) do
    pack_item
    |> cast(attrs, [:item_id, :pack_id])
    |> validate_required([:item_id, :pack_id])
    |> assoc_constraint(:pack)
    |> assoc_constraint(:item)
    |> unique_constraint(:unic_pack_item, name: :index_pack_item, message: "pack item is already taken")
  end

  def import_fields do
    [:item_id]
  end

end

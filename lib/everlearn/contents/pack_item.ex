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
    |> assoc_constraint([:item, :pack])
  end
end

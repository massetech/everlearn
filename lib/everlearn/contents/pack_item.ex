defmodule Everlearn.Contents.PackItem do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.PackItem


  schema "packitems" do
    field :pack_id, :id
    field :item_id, :id

    timestamps()
  end

  @doc false
  def changeset(%PackItem{} = pack_item, attrs) do
    pack_item
    |> cast(attrs, [])
    |> validate_required([])
  end
end

defmodule Everlearn.Contents.Card do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.{Card, Item}

  schema "cards" do
    field :active, :boolean, default: false
    field :language, :string
    field :title, :string
    belongs_to :item, Item

    timestamps()
  end

  @doc false
  def changeset(%Card{} = card, attrs) do
    card
    |> cast(attrs, [:language, :title, :active, :item_id])
    |> validate_required([:language, :title, :active, :item_id])
    |> assoc_constraint(:item)
  end
end

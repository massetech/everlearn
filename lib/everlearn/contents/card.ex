defmodule Everlearn.Contents.Card do
  use Ecto.Schema
  import Ecto.Changeset
  use Rummage.Ecto

  alias Everlearn.Contents.{Card, Item}
  alias Everlearn.Members.{Language}

  schema "cards" do
    field :active, :boolean, default: false
    field :title, :string
    belongs_to :item, Item
    belongs_to :language, Language

    timestamps()
  end

  @doc false
  def changeset(%Card{} = card, attrs) do
    card
    |> cast(attrs, [:title, :active, :item_id, :language_id])
    |> validate_required([:title, :active, :item_id, :language_id])
    |> assoc_constraint(:item)
    |> assoc_constraint(:language)
  end
end

defmodule Everlearn.Contents.Card do
  use Ecto.Schema
  import Ecto.Changeset
  use Rummage.Ecto

  alias Everlearn.Contents.{Card, Item}
  alias Everlearn.Members.{Language}

  schema "cards" do
    field :active, :boolean, default: false
    field :question, :string
    field :answer, :string
    belongs_to :item, Item
    belongs_to :language, Language
    timestamps()
  end

  @doc false
  def changeset(%Card{} = card, attrs) do
    card
    |> cast(attrs, [:question, :answer, :active, :item_id, :language_id])
    |> validate_required([:question, :active, :item_id, :language_id])
    |> assoc_constraint(:item)
    |> assoc_constraint(:language)
    |> unique_constraint(:unic_question_item, name: :index_question_item)
  end
end

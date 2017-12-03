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

  @required_fields ~w(question item_id language_id)a
  @optional_fields ~w(answer active)a

  @doc false
  def changeset(%Card{} = card, attrs) do
    card
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:item)
    |> assoc_constraint(:language)
    |> unique_constraint(:unic_question_item, name: :index_question_item)
  end

  def import_fields do
    [:item_title, :item_level, :language, :question, :answer]
  end

  def filters do
    %{question: "ilike", language_id: "eq", item_id: "eq", active: "eq"}
  end

end

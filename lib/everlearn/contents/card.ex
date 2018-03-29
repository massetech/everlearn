defmodule Everlearn.Contents.Card do
  use Ecto.Schema
  import Ecto.Changeset

  alias Everlearn.Contents.{Card, Item}
  alias Everlearn.Members.{Language, Memory}

  schema "cards" do
    field :active, :boolean, default: false
    field :question, :string, default: ""
    field :answer, :string, default: ""
    field :sound, :string, default: ""
    field :phonetic, :string, default: ""
    belongs_to :item, Item
    belongs_to :language, Language
    has_many :memorys, Memory
    timestamps()
  end

  @required_fields ~w(item_id language_id question)a
  @optional_fields ~w(answer active sound phonetic)a

  @doc false
  def changeset(%Card{} = card, attrs) do
    card
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:item)
    |> assoc_constraint(:language)
    # |> unique_constraint(:unic_question_item, name: :index_question_item)
  end

  def import_fields do
    [:item_title, :item_level, :language, :question, :answer]
  end

  def filters do
    %{id: "eq", language_id: "eq", item_id: "eq", question: "ilike"}
  end

end

defmodule Everlearn.Cards.Card do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Cards.Card


  schema "cards" do
    field :content, :string
    field :language, :string
    field :level, :integer
    field :title, :string
    field :item_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Card{} = card, attrs) do
    card
    |> cast(attrs, [:level, :language, :title, :content])
    |> validate_required([:level, :language, :title, :content])
  end
end

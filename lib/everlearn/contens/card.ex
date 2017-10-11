defmodule Everlearn.Contens.Card do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contens.Card


  schema "cards" do
    field :active, :boolean, default: false
    field :language, :string
    field :title, :string
    field :item_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Card{} = card, attrs) do
    card
    |> cast(attrs, [:language, :title, :active])
    |> validate_required([:language, :title, :active])
  end
end

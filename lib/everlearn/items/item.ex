defmodule Everlearn.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Items.Item


  schema "items" do
    field :active, :boolean, default: false
    field :description, :string
    field :kind, :string
    field :title, :string
    field :topic_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Item{} = item, attrs) do
    item
    |> cast(attrs, [:kind, :title, :description, :active])
    |> validate_required([:kind, :title, :description, :active])
  end
end

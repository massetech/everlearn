defmodule Everlearn.Contents.Item do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.Item


  schema "items" do
    field :active, :boolean, default: false
    field :description, :string
    field :group, :string
    field :level, :integer
    field :title, :string
    field :topic_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Item{} = item, attrs) do
    item
    |> cast(attrs, [:group, :title, :level, :description, :active])
    |> validate_required([:group, :title, :level, :description, :active])
  end
end

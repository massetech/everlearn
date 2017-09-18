defmodule Everlearn.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Groups.Group


  schema "groups" do
    field :active, :boolean, default: false
    field :kind, :string
    field :level, :integer
    field :title, :string
    field :classroom_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Group{} = group, attrs) do
    group
    |> cast(attrs, [:kind, :level, :title, :active])
    |> validate_required([:kind, :level, :title, :active])
  end
end

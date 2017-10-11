defmodule Everlearn.Contents.Pack do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.Pack


  schema "packs" do
    field :active, :boolean, default: false
    field :level, :integer
    field :title, :string
    field :classroom_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Pack{} = pack, attrs) do
    pack
    |> cast(attrs, [:title, :level, :active])
    |> validate_required([:title, :level, :active])
  end
end

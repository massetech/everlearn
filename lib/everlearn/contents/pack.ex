defmodule Everlearn.Contents.Pack do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.{Pack, Classroom, PackItem}
  use Rummage.Ecto

  schema "packs" do
    field :active, :boolean, default: false
    field :level, :integer
    field :title, :string
    field :description, :string
    belongs_to :classroom, Classroom
    has_many :packitems, PackItem
    has_many :items, through: [:packitems, :items]
    timestamps()
  end

  @doc false
  def changeset(%Pack{} = pack, attrs) do
    pack
    |> cast(attrs, [:title, :description, :level, :active, :classroom_id])
    |> validate_required([:title, :description, :level, :active, :classroom_id])
    |> assoc_constraint(:classroom)
  end
end

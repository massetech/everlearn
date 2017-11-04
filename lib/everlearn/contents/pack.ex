defmodule Everlearn.Contents.Pack do
  use Ecto.Schema
  use Rummage.Ecto
  import Ecto.Changeset

  alias Everlearn.Contents.{Pack, Classroom, PackItem}
  alias Everlearn.Members.{Language}

  schema "packs" do
    field :active, :boolean, default: false
    field :level, :integer
    field :title, :string
    field :description, :string
    belongs_to :classroom, Classroom
    belongs_to :language, Language
    has_many :packitems, PackItem
    has_many :items, through: [:packitems, :item]

    timestamps()
  end

  @doc false
  def changeset(%Pack{} = pack, attrs) do
    pack
    |> cast(attrs, [:title, :description, :level, :active, :classroom_id, :language_id])
    |> validate_required([:title, :description, :level, :active, :classroom_id, :language_id])
    |> assoc_constraint(:classroom)
    |> assoc_constraint(:language)
  end
end

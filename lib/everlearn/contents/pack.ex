defmodule Everlearn.Contents.Pack do
  use Ecto.Schema
  use Rummage.Ecto
  import Ecto.Changeset

  alias Everlearn.Contents.{Pack, Classroom, PackItem}
  alias Everlearn.Members.{Language, Membership}

  schema "packs" do
    field :active, :boolean, default: false
    field :vocabulary, :boolean, default: false
    field :level, :integer
    field :title, :string
    field :description, :string
    belongs_to :classroom, Classroom
    belongs_to :language, Language
    has_many :packitems, PackItem
    has_many :items, through: [:packitems, :item]
    has_many :memberships, Membership

    timestamps()
  end

  @required_fields ~w(title description level classroom_id language_id)a
  @optional_fields ~w(vocabulary active)a

  @doc false
  def changeset(%Pack{} = pack, attrs) do
    pack
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:classroom)
    |> assoc_constraint(:language)
  end

  def filters do
    %{title: "ilike", classroom_id: "eq", language_id: "eq", level: "eq", active: "eq"}
  end
end

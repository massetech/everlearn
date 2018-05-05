defmodule Everlearn.Contents.Pack do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.{Pack, Classroom, PackItem, PackLanguage}
  alias Everlearn.Members.{Membership}

  schema "packs" do
    field :active, :boolean, default: false
    field :level, :integer
    field :title, :string
    field :description, :string
    belongs_to :classroom, Classroom
    has_many :packitems, PackItem
    has_many :items, through: [:packitems, :item]
    has_many :cards, through: [:items, :cards]
    has_many :memberships, Membership
    has_many :packlanguages, PackLanguage
    timestamps()
  end

  @required_fields ~w(title description level classroom_id)a
  @optional_fields ~w(active)a

  @doc false
  def changeset(%Pack{} = pack, attrs) do
    pack
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:classroom)
  end

  def filters do
    %{id: "eq", title: "ilike", classroom_id: "eq", level: "eq", active: "eq"}
  end

  def default_filters do
    %{classroom_id: 1}
  end

end

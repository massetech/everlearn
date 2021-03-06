defmodule Everlearn.Contents.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias Everlearn.Contents.{Classroom, Item, Topic, Card, PackItem, Kind}

  schema "items" do
    field :title, :string
    field :picture, :string, default: ""
    field :level, :integer
    field :description, :string
    field :active, :boolean, default: true
    belongs_to :topic, Topic
    belongs_to :kind, Kind
    belongs_to :classroom, Classroom
    has_many :cards, Card
    has_many :packitems, PackItem
    has_many :packs, through: [:packitems, :pack]
    timestamps()
  end

  @required_fields ~w(title level topic_id kind_id classroom_id)a
  @optional_fields ~w(active description picture)a

  @doc false
  def changeset(%Item{} = item, attrs) do
    item
      |> cast(attrs, @required_fields ++ @optional_fields)
      |> validate_required(@required_fields)
      |> validate_inclusion(:level, 1..3)
      |> assoc_constraint(:topic)
      |> assoc_constraint(:kind)
      |> assoc_constraint(:classroom)
      |> unique_constraint(:unic_kind_title_classroom, name: :index_kind_title_classroom, message: "kind title classroom is already taken")
  end

  def filters do
    %{id: "eq", active: "eq", title: "ilike", topic_id: "eq", kind_id: "eq", level: "eq", classroom_id: "eq"}
  end

  def default_filters do
    %{classroom_id: 1}
  end

  def import_fields do
    [:topic_id, :kind_id, :item_id, :title, :level, :description, :picture_link]
  end

end

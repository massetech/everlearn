defmodule Everlearn.Contents.Item do
  use Ecto.Schema
  import Ecto.Changeset
  use Rummage.Ecto

  alias Everlearn.Contents.{Item, Topic, Card, PackItem, Kind}

  schema "items" do
    field :title, :string
    field :level, :integer
    field :description, :string
    field :active, :boolean, default: false
    belongs_to :topic, Topic
    belongs_to :kind, Kind
    has_many :cards, Card
    has_many :packitems, PackItem
    has_many :packs, through: [:packitems, :pack]
    timestamps()
  end

  @required_fields ~w(title level topic_id kind_id)a
  @optional_fields ~w(active description)a

  @doc false
  def changeset(%Item{} = item, attrs) do
    item
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:topic)
    |> assoc_constraint(:kind)
    |> unique_constraint(:unic_title_level, name: :index_title_level)
  end

end

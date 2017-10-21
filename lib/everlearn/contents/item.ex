defmodule Everlearn.Contents.Item do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.{Item, Topic, Card}


  schema "items" do
    field :active, :boolean, default: false
    field :description, :string
    field :group, :string
    field :level, :integer
    field :title, :string
    belongs_to :topic, Topic
    has_many :cards, Card
    timestamps()
  end

  @doc false
  def changeset(%Item{} = item, attrs) do
    item
    |> cast(attrs, [:group, :title, :level, :description, :active, :topic_id])
    |> validate_required([:group, :title, :level, :description, :active, :topic_id])
    |> assoc_constraint(:topic)
  end
end

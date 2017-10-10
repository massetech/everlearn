defmodule Everlearn.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Items.Item

  @fields [:kind, :title, :description, :active, :topic_id]

  schema "items" do
    field :active, :boolean, default: false
    field :description, :string
    field :kind, :string
    field :title, :string
    #field :topic_id, :id
    belongs_to :topic, Everlearn.Topics.Topic
    has_many :cars, Everlearn.Cards.Card, on_delete: :delete_all
    has_many :groupitems, Learnit.GroupItem, on_delete: :delete_all
    many_to_many :groups, Learnit.Group, join_through: Learnit.GroupItem
    timestamps()
  end

  @doc false
  def changeset(%Item{} = item, attrs) do
    item
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end

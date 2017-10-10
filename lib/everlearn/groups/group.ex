defmodule Everlearn.Groups.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Groups.Group

  @fields [:kind, :level, :title, :active, :classroom_id]

  schema "groups" do
    field :active, :boolean, default: false
    field :kind, :string
    field :level, :integer
    field :title, :string
    #field :classroom_id, :id
    belongs_to :classroom, Everlearn.Classrooms.Classroom
    has_many :groupitems, Learnit.GroupItem, on_delete: :delete_all
    many_to_many :items, Learnit.Item, join_through: Learnit.GroupItem
    timestamps()
  end

  @doc false
  def changeset(%Group{} = group, attrs) do
    group
    |> cast(attrs, @fields)
    |> foreign_key_constraint(:classroom_id)
    |> validate_required(@fields)
  end
end

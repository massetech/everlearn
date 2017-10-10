defmodule Everlearn.Topics.Topic do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Topics.Topic

  @fields [:title, :classroom_id]

  schema "topics" do
    field :title, :string
    #field :classroom_id, :id
    belongs_to :classroom, Everlearn.Classrooms.Classroom
    has_many :items, Everlearn.Items.Item, on_delete: :delete_all
    timestamps()
  end

  @doc false
  def changeset(%Topic{} = topic, attrs) do
    topic
    |> cast(attrs, @fields)
    |> foreign_key_constraint(:classroom_id)
    |> validate_required(@fields)
  end
end

defmodule Everlearn.Classrooms.Classroom do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Classrooms.Classroom

  schema "classrooms" do
    field :title, :string
    has_many :topics, Everlearn.Topics.Topic, on_delete: :delete_all
    has_many :groups, Everlearn.Groups.Group, on_delete: :delete_all
    timestamps()
  end

  @doc false
  def changeset(%Classroom{} = classroom, attrs) do
    classroom
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end

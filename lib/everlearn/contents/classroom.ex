defmodule Everlearn.Contents.Classroom do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.{Classroom, Topic}


  schema "classrooms" do
    field :title, :string
    has_many :topics, Topic
    timestamps()
  end

  @doc false
  def changeset(%Classroom{} = classroom, attrs) do
    classroom
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end

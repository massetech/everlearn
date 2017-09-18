defmodule Everlearn.Classrooms.Classroom do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Classrooms.Classroom


  schema "classrooms" do
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(%Classroom{} = classroom, attrs) do
    classroom
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end

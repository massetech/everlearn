defmodule Everlearn.Contents.Classroom do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.{Classroom, Topic, Pack}


  schema "classrooms" do
    field :title, :string
    has_many :topics, Topic
    has_many :packs, Pack
    has_many :items, through: [:topics, :items]
    timestamps()
  end

  @doc false
  def changeset(%Classroom{} = classroom, attrs) do
    classroom
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end

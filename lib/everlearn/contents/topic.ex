defmodule Everlearn.Contents.Topic do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.{Topic, Classroom, Item}

  schema "topics" do
    field :title, :string
    has_many :items, Item

    timestamps()
  end

  @required_fields ~w(title)a
  @optional_fields ~w()a

  @doc false
  def changeset(%Topic{} = topic, attrs) do
    topic
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:title)
  end
end

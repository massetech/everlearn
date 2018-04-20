defmodule Everlearn.Contents.Classroom do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.{Pack, Item, Classroom}

  schema "classrooms" do
    field :title, :string
    field :mono_language, :boolean
    has_many :packs, Pack
    has_many :items, Item
    has_many :memberships, through: [:packs, :memberships]
    timestamps()
  end

  @required_fields ~w(title)a
  @optional_fields ~w(mono_language)a

  @doc false
  def changeset(%Classroom{} = classroom, attrs) do
    classroom
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:title, message: "Title is already taken")
  end
end

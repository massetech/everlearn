defmodule Everlearn.Contents.Kind do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.{Kind, Item}

  schema "kinds" do
    field :title, :string
    has_many :items, Item
    timestamps()
  end

  @required_fields ~w(title)a
  @optional_fields ~w()a

  @doc false
  def changeset(%Kind{} = kind, attrs) do
    kind
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:title, message: "Title is already taken")
  end
end

defmodule Everlearn.Members.Language do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Members.{Language, User}
  alias Everlearn.Contents.{Card}

  schema "languages" do
    field :iso2code, :string
    field :flag, :string
    field :name, :string
    has_many :users, User
    has_many :cards, Card
    timestamps()
  end

  @required_fields ~w(name flag iso2code)a
  @optional_fields ~w()a

  @doc false
  def changeset(%Language{} = language, attrs) do
    language
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:iso2code)
  end
end

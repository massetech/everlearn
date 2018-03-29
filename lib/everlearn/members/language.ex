defmodule Everlearn.Members.Language do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Members.{Language, User, Membership}
  alias Everlearn.Contents.{Card, PackLanguage}

  schema "languages" do
    field :iso2code, :string
    field :title, :string
    has_many :users, User
    has_many :packlanguages, PackLanguage
    has_many :cards, Card
    has_many :student_mbs, Membership, foreign_key: :student_lg
    has_many :teacher_mbs, Membership, foreign_key: :teacher_lg
    timestamps()
  end

  @required_fields ~w(title iso2code)a
  @optional_fields ~w()a

  @doc false
  def changeset(%Language{} = language, attrs) do
    language
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:iso2code, message: "Iso2code is already taken")
  end

  def iso2code_select_btn do
    ["en", "fr", "mm", "cn", "it", "es"]
  end
end

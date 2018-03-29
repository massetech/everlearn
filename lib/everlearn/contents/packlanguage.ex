defmodule Everlearn.Contents.PackLanguage do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.{PackLanguage, Pack}
  alias Everlearn.Members.{Language}

  schema "packlanguages" do
    belongs_to :language, Language
    belongs_to :pack, Pack
    field :title, :string

    timestamps()
  end

  @required_fields ~w(pack_id language_id title)a
  @optional_fields ~w()a

  @doc false
  def changeset(%PackLanguage{} = packlanguage, attrs) do
    packlanguage
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
  end
end

defmodule Everlearn.Members.Language do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Members.{Language, User}
  alias Everlearn.Contents.{Topic}

  schema "languages" do
    field :iso2code, :string
    field :flag, :string
    field :name, :string
    has_many :users, User
    has_many :topics, Topic

    timestamps()
  end

  @doc false
  def changeset(%Language{} = language, attrs) do
    language
    |> cast(attrs, [:name, :flag, :iso2code])
    |> validate_required([:name, :flag, :ISO2code])
  end
end

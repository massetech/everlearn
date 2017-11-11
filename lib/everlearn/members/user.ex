defmodule Everlearn.Members.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Members.{User, Language}

  schema "users" do
    field :uid, :string
    field :email, :string
    field :name, :string
    field :nickname, :string
    field :provider, :string
    field :role, :string, default: "GUEST"
    field :token, :string
    field :token_expiration, :utc_datetime
    belongs_to :language, Language

    timestamps()
  end

  @required_fields ~w(uid email provider token token_expiration)a
  @optional_fields ~w(name nickname role)a

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_inclusion(:provider, ["google", "facebook"])
    |> validate_inclusion(:role, ["GUEST", "MEMBER", "ADMIN", "SUPER"])
    |> assoc_constraint(:language)
  end
end

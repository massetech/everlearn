defmodule Everlearn.Members.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Members.{User, Language}

  schema "users" do
    field :uid, :string
    field :email, :string
    field :name, :string
    field :nickname, :string
    field :main_language, :string, default: "EN"
    field :provider, :string
    field :role, :string, default: "GUEST"
    field :token, :string
    field :token_expiration, :utc_datetime
    belongs_to :language, Language

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:uid, :email, :name, :nickname, :role, :main_language, :provider, :token, :token_expiration, :language_id])
    |> validate_required([:email, :provider, :token, :language_id])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_inclusion(:provider, ["google", "facebook"])
    |> validate_inclusion(:role, ["GUEST", "MEMBER", "ADMIN", "SUPER"])
    # |> validate_inclusion(:main_language, ["EN", "FR"])
    |> assoc_constraint(:language_id)
  end
end

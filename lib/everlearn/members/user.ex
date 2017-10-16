defmodule Everlearn.Members.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Members.User

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

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:uid, :email, :name, :nickname, :role, :main_language, :provider, :token, :token_expiration])
    |> validate_required([:email, :provider, :token])
    |> unique_constraint(:email)
    |> validate_format(:email, ~r/@/)
    |> validate_inclusion(:provider, ["google", "facebook"])
    |> validate_inclusion(:main_language, ["EN", "FR"])
    |> validate_inclusion(:role, ["GUEST", "MEMBER", "ADMIN", "SUPER"])
  end
end

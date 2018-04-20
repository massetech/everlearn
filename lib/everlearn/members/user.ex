defmodule Everlearn.Members.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Members.{User, Language, Membership}

  schema "users" do
    field :uid, :string
    field :email, :string
    field :name, :string
    field :nickname, :string
    field :avatar, :string
    field :provider, :string
    field :role, :string, default: "GUEST"
    field :token, :string
    field :token_expiration, :utc_datetime
    belongs_to :language, Language
    has_many :memberships, Membership
    timestamps()
  end

  @required_fields ~w(uid email provider token token_expiration language_id)a
  @optional_fields ~w(name nickname role avatar)a

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:email, message: "Email is already taken")
    |> validate_format(:email, ~r/@/)
    |> validate_inclusion(:provider, ["google", "facebook"])
    |> validate_inclusion(:role, ["GUEST", "ADMIN", "SUPER"])
    |> assoc_constraint(:language)
  end

  def role_select_btn() do
    [guest: "GUEST", admin: "ADMIN", super: "SUPER"]
  end
end

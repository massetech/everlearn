defmodule Everlearn.Members.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Members.User


  schema "users" do
    field :email, :string
    field :main_language, :string
    field :provider, :string
    field :role, :string
    field :token, :string

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:email, :role, :main_language, :email, :provider, :token])
    |> validate_required([:email, :role, :main_language, :email, :provider, :token])
  end
end

defmodule Everlearn.Members.Membership do
  use Ecto.Schema
  use Rummage.Ecto
  import Ecto.Changeset
  alias Everlearn.Members.{Membership, User}
  alias Everlearn.Contents.Pack

  schema "memberships" do
    belongs_to :user, User
    belongs_to :pack, Pack
    timestamps()
  end

  @required_fields ~w(user_id pack_id)a
  @optional_fields ~w()a

  @doc false
  def changeset(%Membership{} = membership, attrs) do
    membership
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:user)
    |> assoc_constraint(:pack)
  end
end

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

  @doc false
  def changeset(%Membership{} = membership, attrs) do
    membership
    |> cast(attrs, [:user_id, :pack_id])
    |> validate_required([:user_id, :pack_id])
    # |> assoc_constraint(:user)
    # |> assoc_constraint(:pack)
  end
end

defmodule Everlearn.Members.Membership do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Members.Membership


  schema "memberships" do
    field :language, :string
    field :user_id, :id
    field :pack_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Membership{} = membership, attrs) do
    membership
    |> cast(attrs, [:language, :user_id, :pack_id])
    |> validate_required([:language, :user_id, :pack_id])
    |> assoc_constraint(:user)
    |> assoc_constraint(:pack)
  end
end

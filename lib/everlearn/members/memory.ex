defmodule Everlearn.Members.Memory do
  use Ecto.Schema
  import Ecto.Changeset

  alias Everlearn.Members.{Memory, Membership}
  alias Everlearn.Contents.{Card}

  schema "memorys" do
    field :status, :integer
    field :nb_practice, :integer
    belongs_to :membership, Membership
    belongs_to :card, Card
    timestamps()
  end

  @required_fields ~w(membership_id card_id)a
  @optional_fields ~w(status nb_practice)a

  @doc false
  def changeset(%Memory{} = memory, attrs) do
    memory
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:membership)
    |> assoc_constraint(:card)
    |> unique_constraint(:unic_membership_item, name: :index_membership_card, message: "membership item already taken")
  end
end

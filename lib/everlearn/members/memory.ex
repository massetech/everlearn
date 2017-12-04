defmodule Everlearn.Members.Memory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Members.Memory


  schema "memorys" do
    field :status, :string
    field :nb_practice, :integer
    belongs_to :membership, Membership
    belongs_to :item, Item
    timestamps()
  end

  @required_fields ~w(status membership_id item_id)a
  @optional_fields ~w(nb_practice)a

  @doc false
  def changeset(%Memory{} = memory, attrs) do
    memory
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> assoc_constraint(:membership)
    |> assoc_constraint(:item)
    |> unique_constraint(:unic_membership_item, name: :index_membership_item)
  end

  def filters do
    %{status: "eq", membership_id: "eq", item_id: "eq"}
  end

end

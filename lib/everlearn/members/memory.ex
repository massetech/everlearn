defmodule Everlearn.Members.Memory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Members.Memory


  schema "memorys" do
    field :status, :string
    field :nb_practice, :integer
    field :membership_id, :id
    field :item_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Memory{} = memory, attrs) do
    memory
    |> cast(attrs, [:status, :nb_practice, :membership_id, :item_id])
    |> validate_required([:status, :membership_id, :item_id])
    |> assoc_constraint(:membership)
    |> assoc_constraint(:item)
  end
end

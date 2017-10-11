defmodule Everlearn.Members.Memory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Members.Memory


  schema "memorys" do
    field :status, :integer
    field :membership_id, :id
    field :item_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Memory{} = memory, attrs) do
    memory
    |> cast(attrs, [:status])
    |> validate_required([:status])
  end
end

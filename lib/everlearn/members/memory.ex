defmodule Everlearn.Members.Memory do
  use Ecto.Schema
  import Ecto.Changeset

  alias Everlearn.Members.{Memory, Membership}
  alias Everlearn.Contents.{Card}

  schema "memorys" do
    field :status, :integer, default: 0
    field :nb_practice, :integer, default: 0
    field :nb_view, :integer, default: 0
    field :nb_downgrade, :integer, default: 0
    field :user_alert, :boolean, default: false
    field :alert_date, :utc_datetime
    belongs_to :membership, Membership
    belongs_to :card, Card
    timestamps()
  end

  # status
  # 0 : new card not yet learned
  # 1 : card actualy learned
  # 2 : card memorized : short term revision
  # 3 : card known : long term revision

  @required_fields ~w(membership_id card_id)a
  @optional_fields ~w(status nb_practice nb_view nb_downgrade user_alert alert_date)a

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

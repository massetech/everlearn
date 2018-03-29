defmodule Everlearn.Members.Membership do
  use Ecto.Schema
  import Ecto.Changeset

  alias Everlearn.Members.{Membership, User, Memory, Language}
  alias Everlearn.Contents.Pack

  schema "memberships" do
    belongs_to :user, User
    belongs_to :pack, Pack
    belongs_to :student_lg, Language
    belongs_to :teacher_lg, Language
    has_many :items, through: [:pack, :items]
    # belongs_to :student_lg, Language, foreign_key: :student_lg_id
    # belongs_to :teacher_lg, Language, foreign_key: :student_lg_id
    # field :student_lg_id, :integer
    # field :teacher_lg_id, :integer
    has_many :memorys, Memory
    timestamps()
  end

  @required_fields ~w(user_id pack_id student_lg_id)a
  @optional_fields ~w(teacher_lg_id)a

  @doc false
  def changeset(%Membership{} = membership, attrs) do
    membership
      |> cast(attrs, @required_fields ++ @optional_fields)
      |> validate_required(@required_fields)
      |> assoc_constraint(:user)
      |> assoc_constraint(:pack)
  end

  def filters do
    %{user_id: "eq", pack_id: "eq", student_lg_id: "eq", teacher_lg_id: "eq"}
  end

end

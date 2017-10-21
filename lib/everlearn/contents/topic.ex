defmodule Everlearn.Contents.Topic do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.{Topic, Classroom, Item}
  #alias Everlearn.Contents

  schema "topics" do
    field :title, :string
    belongs_to :classroom, Classroom
    has_many :items, Item
    timestamps()
  end

  @doc false
  def changeset(%Topic{} = topic, attrs) do
    topic
    |> cast(attrs, [:title, :classroom_id])
    |> validate_required([:title, :classroom_id])
  end
end

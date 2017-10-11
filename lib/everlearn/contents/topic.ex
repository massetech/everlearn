defmodule Everlearn.Contents.Topic do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Contents.Topic


  schema "topics" do
    field :title, :string
    field :classroom_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Topic{} = topic, attrs) do
    topic
    |> cast(attrs, [:title, :classroom_id])
    |> validate_required([:title, :classroom_id])
  end
end

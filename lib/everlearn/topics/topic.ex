defmodule Everlearn.Topics.Topic do
  use Ecto.Schema
  import Ecto.Changeset
  alias Everlearn.Topics.Topic


  schema "topics" do
    field :title, :string
    field :classroom_id, :id

    timestamps()
  end

  @doc false
  def changeset(%Topic{} = topic, attrs) do
    topic
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end
end

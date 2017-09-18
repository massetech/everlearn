defmodule Everlearn.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :kind, :string
      add :title, :string
      add :description, :string
      add :active, :boolean, default: false, null: false
      add :topic_id, references(:topics, on_delete: :nothing)

      timestamps()
    end

    create index(:items, [:topic_id])
  end
end

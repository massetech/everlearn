defmodule Everlearn.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :group, :string
      add :title, :string
      add :level, :integer
      add :description, :string
      add :active, :boolean, default: false, null: false
      add :topic_id, references(:topics, on_delete: :delete_all)

      timestamps()
    end

    create index(:items, [:topic_id])
  end
end

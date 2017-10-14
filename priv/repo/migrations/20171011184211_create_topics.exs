defmodule Everlearn.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string
      add :classroom_id, references(:classrooms, on_delete: :delete_all)

      timestamps()
    end

    create index(:topics, [:classroom_id])
  end
end

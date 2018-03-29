defmodule Everlearn.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :title, :string
      add :level, :integer
      add :description, :string
      add :active, :boolean, default: true
      add :picture, :string
      add :classroom_id, references(:classrooms, on_delete: :delete_all)
      add :topic_id, references(:topics, on_delete: :delete_all)
      add :kind_id, references(:kinds, on_delete: :delete_all)

      timestamps()
    end
    create index(:items, [:classroom_id])
    create index(:items, [:topic_id])
    create index(:items, [:kind_id])
    # create unique_index(:items, [:title, :level], name: :index_title_level)
  end
end

defmodule Everlearn.Repo.Migrations.CreateClassrooms do
  use Ecto.Migration

  def change do
    create table(:classrooms) do
      add :title, :string
      add :mono_language, :boolean, default: true, null: false
      timestamps()
    end
    create unique_index(:classrooms, [:title])
  end
end

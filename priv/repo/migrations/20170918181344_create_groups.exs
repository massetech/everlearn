defmodule Everlearn.Repo.Migrations.CreateGroups do
  use Ecto.Migration

  def change do
    create table(:groups) do
      add :kind, :string
      add :level, :integer
      add :title, :string
      add :active, :boolean, default: false, null: false
      add :classroom_id, references(:classrooms, on_delete: :nothing)

      timestamps()
    end

    create index(:groups, [:classroom_id])
  end
end

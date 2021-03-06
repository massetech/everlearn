defmodule Everlearn.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :user_id, references(:users, on_delete: :delete_all)
      add :pack_id, references(:packs, on_delete: :delete_all)
      add :student_lg_id, references(:languages, on_delete: :delete_all)
      add :teacher_lg_id, references(:languages, on_delete: :delete_all)

      timestamps()
    end

    create index(:memberships, [:user_id])
    create index(:memberships, [:pack_id])
    create index(:memberships, [:student_lg_id])
    create index(:memberships, [:teacher_lg_id])
  end
end

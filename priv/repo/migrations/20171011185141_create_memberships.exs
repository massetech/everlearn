defmodule Everlearn.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :language, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :pack_id, references(:packs, on_delete: :nothing)

      timestamps()
    end

    create index(:memberships, [:user_id])
    create index(:memberships, [:pack_id])
  end
end
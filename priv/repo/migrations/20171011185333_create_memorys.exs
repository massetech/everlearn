defmodule Everlearn.Repo.Migrations.CreateMemorys do
  use Ecto.Migration

  def change do
    create table(:memorys) do
      add :status, :integer
      add :membership_id, references(:memberships, on_delete: :delete_all)
      add :item_id, references(:items, on_delete: :delete_all)

      timestamps()
    end

    create index(:memorys, [:membership_id])
    create index(:memorys, [:item_id])
  end
end

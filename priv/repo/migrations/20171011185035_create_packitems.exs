defmodule Everlearn.Repo.Migrations.CreatePackitems do
  use Ecto.Migration

  def change do
    create table(:packitems) do
      add :pack_id, references(:packs, on_delete: :nothing)
      add :item_id, references(:items, on_delete: :nothing)

      timestamps()
    end

    create index(:packitems, [:pack_id])
    create index(:packitems, [:item_id])
  end
end

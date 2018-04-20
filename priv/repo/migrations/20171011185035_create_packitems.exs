defmodule Everlearn.Repo.Migrations.CreatePackitems do
  use Ecto.Migration

  def change do
    create table(:packitems) do
      add :pack_id, references(:packs, on_delete: :delete_all)
      add :item_id, references(:items, on_delete: :delete_all)

      timestamps()
    end

    create index(:packitems, [:pack_id])
    create index(:packitems, [:item_id])
    create unique_index(:packitems, [:pack_id, :item_id], name: :index_pack_item)
  end
end

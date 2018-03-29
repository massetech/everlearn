defmodule Everlearn.Repo.Migrations.CreatePacklanguages do
  use Ecto.Migration

  def change do
    create table(:packlanguages) do
      add :language_id, references(:languages, on_delete: :delete_all)
      add :pack_id, references(:packs, on_delete: :delete_all)
      add :title, :string

      timestamps()
    end

    create index(:packlanguages, [:language_id])
    create index(:packlanguages, [:pack_id])
  end
end

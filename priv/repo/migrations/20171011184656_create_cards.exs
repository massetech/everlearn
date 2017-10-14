defmodule Everlearn.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :language, :string
      add :title, :string
      add :active, :boolean, default: false, null: false
      add :item_id, references(:items, on_delete: :delete_all)

      timestamps()
    end

    create index(:cards, [:item_id])
  end
end

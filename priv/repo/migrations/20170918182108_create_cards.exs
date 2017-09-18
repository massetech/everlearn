defmodule Everlearn.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :level, :integer
      add :language, :string
      add :title, :string
      add :content, :string
      add :item_id, references(:items, on_delete: :nothing)

      timestamps()
    end

    create index(:cards, [:item_id])
  end
end

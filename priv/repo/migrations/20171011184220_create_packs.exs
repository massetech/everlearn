defmodule Everlearn.Repo.Migrations.CreatePacks do
  use Ecto.Migration

  def change do
    create table(:packs) do
      add :title, :string
      add :description, :string
      add :level, :integer
      add :vocabulary, :boolean, default: false, null: false
      add :active, :boolean, default: false, null: false
      add :classroom_id, references(:classrooms, on_delete: :delete_all)
      add :language_id, references(:languages, on_delete: :delete_all)

      timestamps()
    end

    create index(:packs, [:classroom_id])
    create index(:packs, [:language_id])
  end
end

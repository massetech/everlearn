defmodule Everlearn.Repo.Migrations.CreatePacks do
  use Ecto.Migration

  def change do
    create table(:packs) do
      add :title, :string
      add :level, :integer
      add :active, :boolean, default: false, null: false
      add :classroom_id, references(:classrooms, on_delete: :delete_all)

      timestamps()
    end

    create index(:packs, [:classroom_id])
  end
end

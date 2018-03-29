defmodule Everlearn.Repo.Migrations.CreateLanguages do
  use Ecto.Migration

  def change do
    create table(:languages) do
      add :title, :string
      add :iso2code, :string

      timestamps()
    end
    create unique_index(:languages, [:iso2code])

  end
end

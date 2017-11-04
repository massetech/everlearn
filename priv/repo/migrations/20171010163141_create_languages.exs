defmodule Everlearn.Repo.Migrations.CreateLanguages do
  use Ecto.Migration

  def change do
    create table(:languages) do
      add :name, :string
      add :flag, :string
      add :code, :string

      timestamps()
    end

  end
end

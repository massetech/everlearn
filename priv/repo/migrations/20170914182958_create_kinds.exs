defmodule Everlearn.Repo.Migrations.CreateKinds do
  use Ecto.Migration

  def change do
    create table(:kinds) do
      add :title, :string

      timestamps()
    end
    create unique_index(:kinds, [:title])
  end
end

defmodule Everlearn.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :role, :string
      add :main_language, :string
      add :email, :string
      add :provider, :string
      add :token, :string

      timestamps()
    end

  end
end

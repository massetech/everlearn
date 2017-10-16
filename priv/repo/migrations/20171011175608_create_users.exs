defmodule Everlearn.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uid, :string
      add :email, :string
      add :name, :string
      add :nickname, :string
      add :role, :string
      add :main_language, :string
      add :provider, :string
      add :token, :string
      add :token_expiration, :utc_datetime

      timestamps()
    end

  end
end

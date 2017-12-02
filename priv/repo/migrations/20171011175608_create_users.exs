defmodule Everlearn.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :uid, :string
      add :email, :string
      add :name, :string
      add :nickname, :string
      add :role, :string
      add :provider, :string
      add :token, :string
      add :token_expiration, :utc_datetime
      add :language_id, references(:languages, on_delete: :delete_all)

      timestamps()
    end
    create index(:users, [:language_id])
    create unique_index(:users, [:email])
  end
end

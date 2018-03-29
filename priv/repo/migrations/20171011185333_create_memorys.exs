defmodule Everlearn.Repo.Migrations.CreateMemorys do
  use Ecto.Migration

  def change do
    create table(:memorys) do
      add :status, :integer, default: 0
      add :nb_practice, :integer, default: 0
      add :membership_id, references(:memberships, on_delete: :delete_all)
      add :card_id, references(:cards, on_delete: :delete_all)
      timestamps()
    end

    create index(:memorys, [:membership_id])
    create index(:memorys, [:card_id])
    create unique_index(:memorys, [:membership_id, :card_id], name: :index_membership_card)
  end
end

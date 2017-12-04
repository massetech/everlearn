defmodule Everlearn.Repo.Migrations.CreateMemorys do
  use Ecto.Migration

  def change do
    create table(:memorys) do
      add :status, :string
      add :nb_practice, :integer
      add :membership_id, references(:memberships, on_delete: :delete_all)
      add :item_id, references(:items, on_delete: :delete_all)

      timestamps()
    end

    create index(:memorys, [:membership_id])
    create index(:memorys, [:item_id])
    create unique_index(:memorys, [:membership_id, :item_id], name: :index_membership_item)
  end
end

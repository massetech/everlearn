defmodule Everlearn.Repo.Migrations.CreateCards do
  use Ecto.Migration

  def change do
    create table(:cards) do
      add :question, :string
      add :answer, :string
      add :sound, :string
      add :phonetic, :string
      add :active, :boolean, default: false, null: false
      add :item_id, references(:items, on_delete: :delete_all)
      add :language_id, references(:languages, on_delete: :delete_all)
      timestamps()
    end

    create index(:cards, [:item_id])
    # create unique_index(:cards, [:question, :item_id], name: :index_question_item)
  end
end

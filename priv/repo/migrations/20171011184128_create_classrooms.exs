defmodule Everlearn.Repo.Migrations.CreateClassrooms do
  use Ecto.Migration

  def change do
    create table(:classrooms) do
      add :title, :string

      timestamps()
    end

  end
end

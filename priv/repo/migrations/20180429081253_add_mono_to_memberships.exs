defmodule Everlearn.Repo.Migrations.AddMonoToMemberships do
  use Ecto.Migration

  def change do
    alter table(:memberships) do
      add :mono_lg, :boolean, default: false
    end
  end
end

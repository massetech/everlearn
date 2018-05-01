defmodule Everlearn.Repo.Migrations.AddFieldsToMemorys do
  use Ecto.Migration

  def change do
    alter table(:memorys) do
      add :nb_view, :integer, default: 0
      add :nb_downgrade, :integer, default: 0
      add :user_alert, :boolean, default: false
      add :alert_date, :utc_datetime
    end
  end
end

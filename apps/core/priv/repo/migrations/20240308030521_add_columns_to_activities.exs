defmodule Core.Repo.Migrations.AddColumnsToActivities do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      add :start_date, :utc_datetime
      add :end_date, :utc_datetime
      add :max_attempts, :integer, default: 1
      add :grade_pass, :float, default: 100
    end
  end
end

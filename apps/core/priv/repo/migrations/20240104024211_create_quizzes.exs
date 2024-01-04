defmodule GoEscuelaLms.Core.Repo.Migrations.CreateQuizzes do
  use Ecto.Migration

  def change do
    create table("quizzes", primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :start_date, :utc_datetime, null: false
      add :end_date, :utc_datetime, null: false
      add :max_attempts, :integer, null: false, default: 1
      add :grade_pass, :float, null: false, default: 100
      add :activity_id, references(:activities, type: :uuid, column: :uuid)
      timestamps()
    end

    create index(:quizzes, [:activity_id])
  end
end

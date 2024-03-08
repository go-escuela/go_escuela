defmodule GoEscuelaLms.Core.Repo.Migrations.CreateEnrollment do
  use Ecto.Migration

  def change do
    create table(:enrollments, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :course_id, references(:courses, type: :uuid, column: :uuid)
      add :user_id, references(:users, type: :uuid, column: :uuid)
      timestamps()
    end

    create unique_index(:enrollments, [:course_id, :user_id], name: :enrollment_course_user_index)
  end
end

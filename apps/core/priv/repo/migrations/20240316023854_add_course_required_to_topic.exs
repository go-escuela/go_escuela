defmodule Core.Repo.Migrations.AddCourseRequiredToTopic do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      modify(:course_id, references(:courses, type: :uuid, column: :uuid),
        null: false,
        from: references(:courses, type: :uuid, column: :uuid)
      )
    end
  end
end

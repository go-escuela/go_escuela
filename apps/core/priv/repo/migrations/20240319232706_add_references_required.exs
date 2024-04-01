defmodule Core.Repo.Migrations.AddReferencesRequired do
  use Ecto.Migration

  def change do
    alter table(:answers) do
      modify(:question_id, references(:questions, type: :uuid, column: :uuid),
        null: false,
        from: references(:questions, type: :uuid, column: :uuid)
      )
    end

    alter table(:questions) do
      modify(:activity_id, references(:activities, type: :uuid, column: :uuid),
        null: false,
        from: references(:activities, type: :uuid, column: :uuid)
      )
    end

    alter table(:enrollments) do
      modify(:course_id, references(:courses, type: :uuid, column: :uuid),
        null: false,
        from: references(:courses, type: :uuid, column: :uuid)
      )

      modify(:user_id, references(:users, type: :uuid, column: :uuid),
      null: false,
      from: references(:users, type: :uuid, column: :uuid)
    )
    end
  end
end

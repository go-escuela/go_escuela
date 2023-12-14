defmodule GoEscuelaLms.Core.Repo.Migrations.CreateCourseIndexTopics do
  use Ecto.Migration

  def change do
     drop index(:topics, [:course_id])
     create index(:topics, [:course_id])
  end
end

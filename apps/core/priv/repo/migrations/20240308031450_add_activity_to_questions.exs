defmodule Core.Repo.Migrations.AddActivityToQuestions do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      add :activity_id, references(:activities, type: :uuid, column: :uuid)
    end
  end
end

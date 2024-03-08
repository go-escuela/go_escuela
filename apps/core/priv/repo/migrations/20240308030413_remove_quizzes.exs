defmodule GoEscuelaLms.Core.Repo.Migrations.RemoveQuizzes do
  use Ecto.Migration

  def change do
    alter table(:questions) do
      remove :quiz_id
    end

    drop table(:quizzes)
  end
end

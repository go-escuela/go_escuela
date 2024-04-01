defmodule Core.Repo.Migrations.AddMatchAnswerToAnswers do
  use Ecto.Migration

  def change do
    alter table(:answers) do
      add :match_answer, :text
    end
  end
end

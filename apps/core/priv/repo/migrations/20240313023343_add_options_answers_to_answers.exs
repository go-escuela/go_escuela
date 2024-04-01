defmodule Core.Repo.Migrations.AddOptionsAnswersToAnswers do
  use Ecto.Migration

  def change do
    alter table(:answers) do
      add :options_answers, {:array, :map}, default: []
    end
  end
end

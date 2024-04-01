defmodule Core.Repo.Migrations.CreateAnswers do
  use Ecto.Migration

  def change do
    create table(:answers, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :description, :text, null: false
      add :feedback, :text
      add :correct_answer, :boolean, null: false,  default: false
      add :mark, :float, null: false, default: 100
      add :question_id, references(:questions, type: :uuid, column: :uuid)
      timestamps()
    end
  end
end

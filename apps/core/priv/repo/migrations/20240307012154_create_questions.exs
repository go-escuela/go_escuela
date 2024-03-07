defmodule GoEscuelaLms.Core.Repo.Migrations.CreateQuestions do
  use Ecto.Migration

  def change do
    create table("questions", primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :title, :string, null: false
      add :description, :text
      add :mark, :float, null: false, default: 100
      add :feedback, :text
      add :question_type, :string, null: false
      add :quiz_id, references(:quizzes, type: :uuid, column: :uuid)
      timestamps()
    end
  end
end

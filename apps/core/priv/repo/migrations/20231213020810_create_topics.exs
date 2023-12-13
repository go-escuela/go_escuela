defmodule GoEscuelaLms.Core.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table("topics", primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :name, :string, null: false
      add :course_id, references(:courses, type: :uuid, column: :uuid)
      timestamps()
    end

    create unique_index(:topics, [:course_id])
  end
end

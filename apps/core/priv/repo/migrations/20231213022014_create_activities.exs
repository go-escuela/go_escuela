defmodule Core.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :name, :string, null: false
      add :enabled, :boolean, default: false
      add :feedback, :text
      add :activity_type, :string
      add :topic_id, references(:topics, type: :uuid, column: :uuid)
      timestamps()
    end

    create unique_index(:activities, [:topic_id])
  end
end

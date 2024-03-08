defmodule GoEscuelaLms.Core.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:activity_files, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :resource, :string, null: false
      add :activity_id, references(:activities, type: :uuid, column: :uuid)
      timestamps()
    end

    create unique_index(:activity_files, [:activity_id])
  end
end

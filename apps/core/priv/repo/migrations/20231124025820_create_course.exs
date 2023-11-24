defmodule GoEscuelaLms.Core.Repo.Migrations.CreateCourse do
  use Ecto.Migration

  def change do
    create table("courses", primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :enabled, :boolean, default: false
      timestamps()
    end
  end
end

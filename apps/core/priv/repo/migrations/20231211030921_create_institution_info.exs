defmodule Core.Repo.Migrations.CreateInstitutionInfo do
  use Ecto.Migration

  def change do
    create table(:institution_info, primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :name, :string, null: false
      timestamps()
    end
  end
end

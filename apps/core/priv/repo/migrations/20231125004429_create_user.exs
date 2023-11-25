defmodule GoEscuelaLms.Core.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table("users", primary_key: false) do
      add :uuid, :uuid, primary_key: true
      add :full_name, :string, null: false
      add :email, :string
      add :birth_date, :date
      add :role, :string
      timestamps()
    end
  end
end

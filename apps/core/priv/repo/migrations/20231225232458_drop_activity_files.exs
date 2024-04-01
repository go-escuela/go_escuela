defmodule Core.Repo.Migrations.DropActivityFiles do
  use Ecto.Migration

  def change do
    drop table(:activity_files)
  end
end

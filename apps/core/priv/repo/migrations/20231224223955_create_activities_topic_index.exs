defmodule Core.Repo.Migrations.CreateActivitiesTopicIndex do
  use Ecto.Migration

  def change do
    drop index(:activities, [:topic_id])
    create index(:activities, [:topic_id])
  end
end

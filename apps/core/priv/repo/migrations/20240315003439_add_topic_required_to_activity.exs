defmodule GoEscuelaLms.Core.Repo.Migrations.AddTopicRequiredToActivity do
  use Ecto.Migration

  def change do
    alter table(:activities) do
      modify :topic_id, references(:topics, type: :uuid, column: :uuid), null: false, from: references(:topics, type: :uuid, column: :uuid)
    end
  end
end

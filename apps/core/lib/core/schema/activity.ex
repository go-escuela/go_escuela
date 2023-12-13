defmodule GoEscuelaLms.Core.Schema.Activity do
  @moduledoc """
  This module represents the Activity schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias GoEscuelaLms.Core.Schema.Topic

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "activities" do
    field(:name, :string)
    field(:enabled, :boolean, default: false)
    field(:feedback, :string)
    field(:activity_type, Ecto.Enum, values: [:resource, :quiz])

    belongs_to(:topic, Topic, references: :uuid)

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :enabled, :feedback, :activity_type, :topic_id])
    |> validate_required([:name, :activity_type, :topic_id])
  end
end

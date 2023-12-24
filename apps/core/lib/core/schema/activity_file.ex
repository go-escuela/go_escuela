defmodule GoEscuelaLms.Core.Schema.ActivityFile do
  @moduledoc """
  This module represents the Activity schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias GoEscuelaLms.Core.Schema.Activity

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "activity_files" do
    field(:resource, :string)

    belongs_to(:activity, Activity, references: :uuid)

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:resource, :activity_id])
    |> validate_required([:resource, :activity_id])
  end
end

defmodule GoEscuelaLms.Core.Schema.ActivityFile do
  @moduledoc """
  This module represents the Activity schema
  """
  __MODULE__
  use Ecto.Schema
  use Waffle.Ecto.Schema

  import Ecto.Changeset

  alias GoEscuelaLms.Core.Schema.Activity
  alias Core.ResourceUploader

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "activity_files" do
    field(:resource, ResourceUploader.Type)

    belongs_to(:activity, Activity, references: :uuid)

    timestamps()
  end

  def changeset(activity_file, attrs) do
    activity_file
    |> cast(attrs, [:resource, :activity_id])
    |> cast_attachments(attrs, [:resource])
    |> validate_required([:resource, :activity_id])
  end
end

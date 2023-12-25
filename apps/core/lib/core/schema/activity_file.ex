defmodule GoEscuelaLms.Core.Schema.ActivityFile do
  @moduledoc """
  This module represents the Activity resources files schema
  """
  use Ecto.Schema

  import Ecto.Changeset
  # import Ecto.Query

  alias __MODULE__
  alias GoEscuelaLms.Core.Repo, as: Repo
  alias GoEscuelaLms.Core.Schema.Activity
  # alias GoEscuelaLms.Core.GCP.Manager, as: GCPManager

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "activity_files" do
    field(:resource, :string)

    belongs_to(:activity, Activity, references: :uuid)

    timestamps()
  end

  def create(attrs \\ %{}) do
    %ActivityFile{}
    |> ActivityFile.changeset(attrs)
    |> Repo.insert()
  end

  def find(uuid) do
    Repo.get(ActivityFile, uuid)
    |> Repo.preload(:activity)
  end

  def changeset(activity_file, attrs) do
    activity_file
    |> cast(attrs, [:resource, :activity_id])
    |> validate_required([:resource, :activity_id])
  end
end

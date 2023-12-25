defmodule GoEscuelaLms.Core.Schema.Activity do
  @moduledoc """
  This module represents the Activity schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias GoEscuelaLms.Core.Repo, as: Repo
  alias GoEscuelaLms.Core.Schema.{Topic, Activity, ActivityFile}
  alias GoEscuelaLms.Core.GCP.Manager, as: GCPManager

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "activities" do
    field(:name, :string)
    field(:enabled, :boolean, default: false)
    field(:feedback, :string)
    field(:activity_type, Ecto.Enum, values: [:resource, :quiz])

    belongs_to(:topic, Topic, references: :uuid)
    has_many(:activity_files, ActivityFile, foreign_key: :activity_id)

    timestamps()
  end

  def create(attrs \\ %{}) do
    %Activity{}
    |> Activity.changeset(attrs)
    |> Repo.insert()
  end

  def create_with_resource(attrs \\ %{}) do
    Repo.transaction(fn ->
      with {:ok, activity} <- Activity.create(attrs),
           {:ok, _message} <- GCPManager.upload(activity, attrs[:resource]) do

      activity
      else
        error ->
          Repo.rollback({:failed, error})
      end
    end)
  end

  def activity_types, do: Ecto.Enum.dump_values(Activity, :activity_type)

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :enabled, :feedback, :activity_type, :topic_id])
    |> validate_required([:name, :activity_type, :topic_id])
  end
end

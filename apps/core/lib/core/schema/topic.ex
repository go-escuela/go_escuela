defmodule Core.Schema.Topic do
  @moduledoc """
  This module represents the topic schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Core.Repo, as: Repo
  alias Core.Schema.{Course, Activity}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "topics" do
    field(:name, :string)

    belongs_to(:course, Course, references: :uuid)
    has_many(:activities, Activity, foreign_key: :topic_id)

    timestamps()
  end

  def find(uuid) do
    Repo.get(Topic, uuid)
    |> Repo.preload(:course)
    |> Repo.preload(:activities)
  end

  def create(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Topic{} = topic, attrs) do
    topic
    |> changeset(attrs)
    |> Repo.update()
  end

  def delete(%Topic{} = topic) do
    topic |> Repo.delete()
  end

  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:name, :course_id])
    |> validate_required([:name, :course_id])
  end
end

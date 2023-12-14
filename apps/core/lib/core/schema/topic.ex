defmodule GoEscuelaLms.Core.Schema.Topic do
  @moduledoc """
  This module represents the topic schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias GoEscuelaLms.Core.Repo, as: Repo
  alias GoEscuelaLms.Core.Schema.{Course, Activity}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "topics" do
    field(:name, :string)

    belongs_to(:course, Course, references: :uuid)
    has_many(:activities, Activity, foreign_key: :topic_id)

    timestamps()
  end

  def create(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :course_id])
    |> validate_required([:name, :course_id])
  end
end

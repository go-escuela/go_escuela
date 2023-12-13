defmodule GoEscuelaLms.Core.Schema.Course do
  @moduledoc """
  This module represents the Course schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias GoEscuelaLms.Core.Repo, as: Repo

  alias GoEscuelaLms.Core.Schema.{Enrollment, Topic}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}

  schema "courses" do
    field(:name, :string)
    field(:description, :string)
    field(:enabled, :boolean, default: false)

    has_many(:enrollments, Enrollment, foreign_key: :course_id)
    has_many(:topics, Topic, foreign_key: :course_id)

    timestamps()
  end

  def create(attrs \\ %{}) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :description, :enabled])
    |> validate_required([:name])
  end
end

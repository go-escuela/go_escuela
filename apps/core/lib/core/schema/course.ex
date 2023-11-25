defmodule GoEscuelaLms.Core.Schema.Course do
  @moduledoc """
  This module represents the audit schema. Audits are the read models for events.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias GoEscuelaLms.Core.Schema.{Enrollment}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}

  schema "courses" do
    field(:name, :string)
    field(:description, :string)
    field(:enabled, :boolean, default: false)

    has_many(:enrollments, Enrollment, foreign_key: :course_id)

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :description, :enabled])
    |> validate_required([:name])
  end
end

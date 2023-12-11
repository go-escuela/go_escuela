defmodule GoEscuelaLms.Core.Schema.Enrollment do
  @moduledoc """
  This module represents the enrollment schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias GoEscuelaLms.Core.Schema.{Course, User}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "enrollments" do
    belongs_to(:course, Course, references: :uuid)
    belongs_to(:user, User, references: :uuid)

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:course_id, :user_id])
    |> validate_required([:course_id, :user_id])
  end
end

defmodule GoEscuelaLms.Core.Schema.Topic do
  @moduledoc """
  This module represents the enrollment schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias GoEscuelaLms.Core.Schema.Course

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "topics" do
    field(:name, :string)

    belongs_to(:course, Course, references: :uuid)

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :course_id])
    |> validate_required([:name, :course_id])
  end
end

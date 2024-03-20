defmodule GoEscuelaLms.Core.Schema.Course do
  @moduledoc """
  This module represents the Course schema.
  """

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

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

  def all, do: Repo.all(Course)

  def all(user_id) do
    query =
      from(c in Course,
        join: e in Enrollment,
        on: c.uuid == e.course_id,
        where: e.user_id == ^user_id
      )

    Repo.all(query)
  end

  def find(uuid) do
    case Ecto.UUID.dump(uuid) do
      {:ok, _} ->
        Repo.get(Course, uuid)
        |> Repo.preload(:topics)
        |> Repo.preload(:enrollments)

      _ ->
        nil
    end
  end

  def create(attrs \\ %{}) do
    %Course{}
    |> Course.changeset(attrs)
    |> Repo.insert()
  end

  def update(%Course{} = course, attrs) do
    course
    |> changeset(attrs)
    |> Repo.update()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :description, :enabled])
    |> validate_required([:name])
  end
end

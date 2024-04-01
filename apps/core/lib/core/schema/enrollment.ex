defmodule Core.Schema.Enrollment do
  @moduledoc """
  This module represents the enrollment schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias Core.Repo, as: Repo
  alias Core.Schema.{Course, User}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "enrollments" do
    belongs_to(:course, Course, references: :uuid)
    belongs_to(:user, User, references: :uuid)

    timestamps()
  end

  def all, do: Repo.all(Enrollment)

  def find(uuid) do
    Repo.get(Enrollment, uuid)
    |> Repo.preload(:course)
    |> Repo.preload(:user)
  end

  def create(attrs \\ %{}) do
    %Enrollment{}
    |> Enrollment.changeset(attrs)
    |> Repo.insert()
  end

  def delete(%Enrollment{} = enrollment) do
    enrollment |> Repo.delete()
  end

  def changeset(enrollment, attrs) do
    enrollment
    |> cast(attrs, [:course_id, :user_id])
    |> validate_required([:course_id, :user_id])
    |> unique_constraint(:user,
      name: :enrollment_course_user_index,
      message: "user is already enrollment"
    )
  end
end

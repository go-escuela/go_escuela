defmodule GoEscuelaLms.Core.Schema.Quiz do
  @moduledoc """
  This module represents the quizzes schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias GoEscuelaLms.Core.Repo, as: Repo
  alias GoEscuelaLms.Core.Schema.{Activity}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "quizzes" do
    field(:start_date, :utc_datetime)
    field(:end_date, :utc_datetime)
    field(:max_attempts, :integer)
    field(:grade_pass, :float)

    belongs_to(:activity, Activity, references: :uuid)
    timestamps()
  end

  def create(activity, attrs \\ %{}) do
    attrs = attrs |> Map.merge(%{activity_id: activity.uuid})

    %Quiz{}
    |> Quiz.changeset(attrs)
    |> Repo.insert()
  end

  def changeset(quiz, attrs) do
    quiz
    |> cast(attrs, [:start_date, :end_date, :max_attempts, :grade_pass, :activity_id])
    |> validate_required([:start_date, :end_date, :activity_id])
  end
end

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
    field(:attempts, :integer)
    field(:grade_pass, :float)

    belongs_to(:activity, Activity, references: :uuid)
    timestamps()
  end

  def create(attrs \\ %{}) do
    %Quiz{}
    |> Quiz.changeset(attrs)
    |> Repo.insert()
  end

  def changeset(quiz, attrs) do
    quiz
    |> cast(attrs, [:start_date, :end_date, :attempts, :grade_pass, :Activity_id])
    |> validate_required([:start_date, :end_date, :Activity_id])
  end
end

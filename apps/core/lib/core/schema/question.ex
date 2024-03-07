defmodule GoEscuelaLms.Core.Schema.Question do
  @moduledoc """
  This module represents the questions schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias GoEscuelaLms.Core.Repo, as: Repo
  alias GoEscuelaLms.Core.Schema.{Quiz}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "questions" do
    field(:title, :string)
    field(:description, :string)
    field(:mark, :float)
    field(:feedback, :string)

    field(:question_type, Ecto.Enum,
      values: [:true_false, :multiple_choice, :matching, :completion, :open_answer]
    )

    belongs_to(:quiz, Quiz, references: :uuid)
    timestamps()
  end

  def all, do: Repo.all(Question)

  def create(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  def question_types, do: Ecto.Enum.dump_values(Question, :question_type)

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :enabled, :feedback, :activity_type, :topic_id])
    |> validate_required([:name, :activity_type, :topic_id])
  end
end

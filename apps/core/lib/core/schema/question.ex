defmodule GoEscuelaLms.Core.Schema.Question do
  @moduledoc """
  This module represents the questions schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias GoEscuelaLms.Core.Repo, as: Repo
  alias GoEscuelaLms.Core.Schema.{Activity, Answer}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "questions" do
    field(:title, :string)
    field(:description, :string)
    field(:mark, :float)
    field(:feedback, :string)

    field(:question_type, Ecto.Enum,
      values: [:true_false, :multiple_choice, :open_answer, :matching, :completion]
    )

    belongs_to(:activity, Activity, references: :uuid)
    has_many(:answers, Answer, foreign_key: :question_id, on_delete: :delete_all)
    timestamps()
  end

  def all, do: Repo.all(Question)

  def bulk_create(activity, records) do
    Repo.transaction(fn ->
      Enum.each(records, fn record ->
        question =
          Question.changeset(%Question{activity_id: activity.uuid}, record)
          |> Repo.insert!()

        Answer.bulk_create(question, record.answers)
      end)

      :ok
    end)
  end

  def create(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  def question_types, do: Ecto.Enum.dump_values(Question, :question_type)

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:title, :description, :mark, :feedback, :question_type, :activity_id])
    |> validate_required([:title, :mark, :question_type, :activity_id])
  end
end

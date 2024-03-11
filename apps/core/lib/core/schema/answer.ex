defmodule GoEscuelaLms.Core.Schema.Answer do
  @moduledoc """
  This module represents the answers schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias GoEscuelaLms.Core.Repo, as: Repo
  alias GoEscuelaLms.Core.Schema.{Question}

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "answers" do
    field(:description, :string)
    field(:feedback, :string)
    field(:correct_answer, :boolean)

    belongs_to(:question, Question, references: :uuid)
    timestamps()
  end

  def all, do: Repo.all(Answer)

  def create(attrs \\ %{}) do
    %Answer{}
    |> Answer.changeset(attrs)
    |> Repo.insert()
  end

  def bulk_create(_question, records) when is_nil(records), do: :ok

  def bulk_create(question, records) do
    Enum.each(records, fn record ->
      Answer.changeset(%Answer{question_id: question.uuid}, record)
      |> Repo.insert!()
    end)
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:description, :feedback, :correct_answer, :question_id])
    |> validate_required([:description, :correct_answer, :question_id])
  end
end

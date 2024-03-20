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
    # is using when the question is matching
    field(:match_answer, :string)
    field(:feedback, :string)
    field(:correct_answer, :boolean)
    field(:options_answers, {:array, :map})

    belongs_to(:question, Question, references: :uuid)
    timestamps()
  end

  def all, do: Repo.all(Answer)

  def find(uuid) do
    case Ecto.UUID.dump(uuid) do
      {:ok, _} ->
        Repo.get(Answer, uuid)

      _ ->
        nil
    end
  end

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
    |> cast(attrs, [
      :description,
      :match_answer,
      :feedback,
      :correct_answer,
      :question_id,
      :options_answers
    ])
    |> add_options_answers_if_missing()
    |> validate_required([:description, :correct_answer, :question_id])
  end

  defp add_options_answers_if_missing(%Ecto.Changeset{changes: %{options_answers: _}} = changeset) do
    changeset
  end

  defp add_options_answers_if_missing(
         %Ecto.Changeset{data: %Answer{options_answers: nil}} = changeset
       ) do
    changeset
    |> put_change(:options_answers, [])
  end

  defp add_options_answers_if_missing(changeset) do
    changeset
  end
end

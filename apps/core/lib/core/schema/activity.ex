defmodule GoEscuelaLms.Core.Schema.Activity do
  @moduledoc """
  This module represents the activities schema
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias __MODULE__
  alias GoEscuelaLms.Core.Repo, as: Repo
  alias GoEscuelaLms.Core.Schema.{Topic, Quiz, Question}
  alias GoEscuelaLms.Core.GCP.Manager, as: GCPManager

  @primary_key {:uuid, Ecto.UUID, autogenerate: true}
  @foreign_key_type :binary_id

  schema "activities" do
    field(:name, :string)
    field(:enabled, :boolean, default: false)
    field(:feedback, :string)
    field(:activity_type, Ecto.Enum, values: [:resource, :quiz])

    belongs_to(:topic, Topic, references: :uuid)
    has_many(:quizzes, Quiz, foreign_key: :activity_id, on_delete: :delete_all)
    timestamps()
  end

  def all, do: Repo.all(Activity)

  def find(uuid) do
    Repo.get(Activity, uuid)
    |> Repo.preload(quizzes: [questions: :answers])
  end

  def create(attrs \\ %{}) do
    %Activity{}
    |> Activity.changeset(attrs)
    |> Repo.insert()
  end

  def create_with_resource(attrs \\ %{}) do
    Repo.transaction(fn ->
      with {:ok, activity} <- Activity.create(attrs),
           {:ok, _response} <- GCPManager.upload(activity, attrs[:resource]) do
        activity
      else
        error ->
          Repo.rollback({:failed, error})
      end
    end)
  end

  def create_with_quiz(attrs \\ %{}) do
    Repo.transaction(fn ->
      with {:ok, activity} <- Activity.create(attrs),
           {:ok, quiz} <- Quiz.create(activity, attrs),
           {:ok, :ok} <- Question.bulk_create(quiz, attrs.questions) do
        activity
      else
        error ->
          IO.puts("#{inspect(error)}")
          Repo.rollback({:failed, error})
      end
    end)
  end

  def activity_types, do: Ecto.Enum.dump_values(Activity, :activity_type)

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :enabled, :feedback, :activity_type, :topic_id])
    |> validate_required([:name, :activity_type, :topic_id])
  end
end

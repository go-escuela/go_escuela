defmodule Core.QuestionTest do
  use ExUnit.Case
  use Core.DataCase

  import Core.Factory

  alias GoEscuelaLms.Core.Repo
  alias GoEscuelaLms.Core.Schema.Question

  setup do
    course = insert!(:course)
    topic = insert!(:topic, course_id: course.uuid)
    activity = insert!(:activity, topic_id: topic.uuid)
    {:ok, activity: activity}
  end

  describe "schema" do
    test "metadata", _context do
      assert Question.__schema__(:source) == "questions"

      assert Question.__schema__(:fields) == [
               :uuid,
               :title,
               :description,
               :mark,
               :feedback,
               :question_type,
               :activity_id,
               :inserted_at,
               :updated_at
             ]
    end

    test "associations", _context do
      assert Question.__schema__(:association, :answers).__struct__ == Ecto.Association.Has
      assert Question.__schema__(:association, :activity).__struct__ == Ecto.Association.BelongsTo
    end
  end

  describe("all/1") do
    test "should return all questions", %{activity: activity} do
      Enum.each(0..3, fn _ ->
        insert!(:question, activity_id: activity.uuid)
      end)

      assert Question.all() |> Enum.count() == 4
    end
  end

  describe "find/1" do
    test "when exist", %{activity: activity} do
      question = insert!(:question, activity_id: activity.uuid) |> Repo.preload(:answers)

      assert Question.find(question.uuid) == question
    end

    test "when does not exist", _context do
      assert Question.find("28a11d64-5fd9-4028-8707-aeac06c7d10e") == nil
    end
  end

  describe "create/1" do
    test "create valid question", %{activity: activity} do
      question =
        build(:question, activity_id: activity.uuid) |> Map.from_struct()

      {:ok, question_created} = Question.create(question)

      assert question_created.title == question.title
      assert question_created.description == question.description
      assert question_created.mark == question.mark
      assert question_created.question_type == question.question_type
      assert question_created.feedback == question.feedback
    end

    test "invalid create question", _context do
      {:error, errors} = Question.create(%{})
      assert errors.valid? == false
    end
  end

  describe "bulk_create/2" do
    test "valid create multiple answers", %{activity: activity} do
      questions =
        [
          build(:question, activity_id: activity.uuid, answers: []) |> Map.from_struct(),
          build(:question, activity_id: activity.uuid, answers: []) |> Map.from_struct()
        ]

      assert Question.bulk_create(activity, questions) == {:ok, :ok}
    end
  end

  describe "questions_types/0" do
    test "return all activity_types", _context do
      assert Question.question_types() == [
               "true_false",
               "multiple_choice",
               "open_answer",
               "missing",
               "matching"
             ]
    end
  end
end

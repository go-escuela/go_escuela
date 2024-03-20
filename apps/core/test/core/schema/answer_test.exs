defmodule Core.AnswerTest do
  use ExUnit.Case
  use Core.DataCase

  import Core.Factory

  alias GoEscuelaLms.Core.Schema.Answer

  setup do
    course = insert!(:course)
    topic = insert!(:topic, course_id: course.uuid)
    activity = insert!(:activity, topic_id: topic.uuid)
    question = insert!(:question, activity_id: activity.uuid)
    {:ok, question: question}
  end

  describe "schema" do
    test "metadata", _context do
      assert Answer.__schema__(:source) == "answers"

      assert Answer.__schema__(:fields) == [
               :uuid,
               :description,
               :match_answer,
               :feedback,
               :correct_answer,
               :options_answers,
               :question_id,
               :inserted_at,
               :updated_at
             ]
    end

    test "types metadata", _context do
      assert Answer.__schema__(:type, :uuid) == Ecto.UUID
      assert Answer.__schema__(:type, :description) == :string
      assert Answer.__schema__(:type, :feedback) == :string
      assert Answer.__schema__(:type, :correct_answer) == :boolean
      assert Answer.__schema__(:type, :options_answers) == {:array, :map}
    end

    test "associations", _context do
      assert Answer.__schema__(:association, :question).__struct__ == Ecto.Association.BelongsTo
    end
  end

  describe "all/0" do
    test "should return all answers", %{question: question} = _context do
      Enum.each(0..3, fn _ -> insert!(:answer, question_id: question.uuid) end)

      assert Answer.all() |> Enum.count() == 4
    end
  end

  describe "find/1" do
    test "when exist", %{question: question} = _context do
      answer = insert!(:answer, question_id: question.uuid)

      assert Answer.find(answer.uuid) == answer
    end

    test "when does not exist", _context do
      assert Answer.find("28a11d64-5fd9-4028-8707-aeac06c7d10e") == nil
    end

    test "with invalid uuid", _context do
      assert Answer.find("xxxx") == nil
      assert Answer.find(nil) == nil
    end
  end

  describe "create/1" do
    test "create valid answer", %{question: question} = _context do
      answer =
        build(:answer, question_id: question.uuid) |> Map.from_struct()

      {:ok, created_answer} = Answer.create(answer)

      assert created_answer.description == answer.description
      assert created_answer.feedback == answer.feedback
      assert created_answer.correct_answer == answer.correct_answer
      assert created_answer.options_answers == answer.options_answers
    end

    test "invalid create answer", _context do
      {:error, errors} = Answer.create(%{})

      assert errors.valid? == false
    end
  end

  describe "bulk_create/2" do
    test "when is nil", %{question: question} = _context do
      assert Answer.bulk_create(question, nil) == :ok
      assert Answer.bulk_create(question, []) == :ok
    end

    test "valid create multiple answers", %{question: question} = _context do
      answers =
        [
          build(:answer, question_id: question.uuid) |> Map.from_struct(),
          build(:answer, question_id: question.uuid) |> Map.from_struct()
        ]

      assert Answer.bulk_create(question, answers) == :ok
    end
  end
end

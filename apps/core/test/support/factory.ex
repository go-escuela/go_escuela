defmodule Core.Factory do
  @moduledoc """
  Schema data factories
  """

  alias GoEscuelaLms.Core.Repo
  alias GoEscuelaLms.Core.Schema.{Activity, Answer, Course, Question, Topic}

  def build(:activity) do
    %Activity{
      name: Faker.Lorem.sentence(),
      enabled: true,
      feedback: nil,
      start_date: DateTime.truncate(DateTime.utc_now(), :second),
      end_date: DateTime.truncate(DateTime.utc_now(), :second),
      max_attempts: 1,
      grade_pass: 70.0,
      activity_type: :quiz
    }
  end

  def build(:topic) do
    %Topic{
      name: Faker.Lorem.word(),
      course_id: nil
    }
  end

  def build(:course) do
    %Course{
      name: Faker.Lorem.word(),
      description: nil,
      enabled: true
    }
  end

  def build(:question) do
    %Question{
      tittle: Faker.Lorem.word(),
      description: nil,
      mark: true,
      feedback: true
    }
  end

  def build(:answer) do
    %Answer{
      description: Faker.Lorem.word(),
      match_answer: nil,
      feedback: nil,
      correct_answer: :answer
    }
  end

  # Convenience API

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end

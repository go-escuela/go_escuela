defmodule Core.Factory do
  @moduledoc """
  Schema data factories
  """

  alias Core.Repo

  alias Core.Schema.{
    Activity,
    Answer,
    Course,
    Enrollment,
    InstitutionInfo,
    Question,
    Topic,
    User
  }

  def build(:activity) do
    %Activity{
      name: Faker.Lorem.sentence(),
      enabled: true,
      feedback: Faker.Lorem.sentence(),
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
      description: Faker.Lorem.sentence(),
      enabled: true
    }
  end

  def build(:question) do
    %Question{
      title: Faker.Lorem.sentence(),
      description: Faker.Lorem.sentence(),
      mark: 10.0,
      feedback: Faker.Lorem.sentence(),
      question_type: :multiple_choice
    }
  end

  def build(:answer) do
    %Answer{
      description: Faker.Lorem.word(),
      match_answer: nil,
      feedback: Faker.Lorem.sentence(),
      options_answers: [],
      correct_answer: true
    }
  end

  def build(:enrollment) do
    %Enrollment{}
  end

  def build(:user) do
    %User{
      full_name: Faker.Person.name(),
      email: Faker.Internet.email(),
      role: :instructor,
      password_hash: Faker.String.base64(100)
    }
  end

  def build(:institution_info) do
    %InstitutionInfo{
      name: Faker.App.name()
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

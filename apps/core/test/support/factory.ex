defmodule Core.Factory do
  alias GoEscuelaLms.Core.Repo
  alias GoEscuelaLms.Core.Schema.{Activity, Answer, Question}

  def build(:activity) do
    %Activity{
      name: Faker.Lorem.word(),
      enabled: true,
      feedback: nil,
      start_date: DateTime.truncate(DateTime.utc_now(), :second),
      end_date: DateTime.truncate(DateTime.utc_now(), :second),
      max_attempts: 1,
      grade_pass: 70.0,
      activity_type: :resource
      # questions: [
      # 	build(:questions),
      #   build(:questions)
      # ]
    }
  end

  # def build(:question) do
  #   %Question{
  #     body: "good post",
  #     answers: [
  #       build(:answers, body: "first"),
  #       build(:answers, body: "second")
  #     ]
  #   }
  # end

  # def build(:answers) do
  #   %Answer{
  #     title: "hello with answers"
  #   }
  # end

  # Convenience API

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end

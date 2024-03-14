defmodule Core.Factory do
  @moduledoc """
  Schema data factories
  """

  alias GoEscuelaLms.Core.Repo
  alias GoEscuelaLms.Core.Schema.{Activity}

  def build(:activity) do
    %Activity{
      name: Faker.Lorem.word(),
      enabled: true,
      feedback: nil,
      start_date: DateTime.truncate(DateTime.utc_now(), :second),
      end_date: DateTime.truncate(DateTime.utc_now(), :second),
      max_attempts: 1,
      grade_pass: 70.0,
      activity_type: :quiz
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

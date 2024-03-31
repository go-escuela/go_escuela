defmodule Web.Activities.ActivitiesController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug
  import Web.Plug.CheckRequest

  alias GoEscuelaLms.Core.Schema.{Activity, Question}

  plug :permit_authorized when action in [:create]
  plug :load_course when action in [:create]
  plug :load_topic when action in [:create]
  plug :check_enrollment when action in [:create]

  @create_params %{
    name: [type: :string, required: true],
    activity_type: [type: :string, required: true, in: Activity.activity_types()],
    feedback: :string,
    enabled: :boolean,
    start_date: [type: :naive_datetime],
    end_date: [type: :naive_datetime],
    max_attempts: :integer,
    grade_pass: :float
  }

  @quiz_params %{
    questions: [
      type:
        {:array,
         %{
           title: [type: :string, required: true],
           description: [type: :string, required: {__MODULE__, :require_question_description?}],
           feedback: [type: :string],
           mark: [type: :float, required: true],
           question_type: [type: :string, required: true, in: Question.question_types()],
           answers: [
             type:
               {:array,
                %{
                  description: [type: :string, required: true],
                  feedback: [type: :string],
                  match_answer: [type: :string],
                  options_answers: [
                    type:
                      {:array,
                       %{
                         statement: [type: :string, required: true],
                         correct_answer: [type: :boolean, required: true]
                       }}
                  ],
                  correct_answer: [type: :boolean, required: true]
                }},
             required: {__MODULE__, :require_answers?}
           ]
         }},
      required: true
    ]
  }

  def create(conn, params) do
    topic = conn.assigns.object

    with {:ok, valid_params} <- Tarams.cast(params, @create_params),
         {:ok, valid_params} <- activity_type_valid_params(params, valid_params),
         {:ok, _} <- answers_cast_params(params),
         {:ok, activity} <- create_activity(topic, params, valid_params) do
      render(conn, :create, %{activity: activity})
    end
  end

  defp activity_type_valid_params(params, %{activity_type: activity_type} = valid_params) do
    case activity_type do
      "quiz" ->
        create_params = @create_params |> Map.merge(@quiz_params)
        Tarams.cast(params, create_params)

      # resource  activity type -> file upload required
      _ ->
        if is_nil(params |> get_in(["resource"])) do
          {:error, "file is empty"}
        else
          {:ok, valid_params}
        end
    end
  end

  def answers_cast_params(%{"activity_type" => activity_type} = params)
      when activity_type in ~w(resource),
      do: {:ok, params}

  def answers_cast_params(params) do
    result =
      params
      |> get_in(["questions"])
      |> Enum.map(fn question ->
        answers = question |> get_in(["answers"]) || []
        title = question |> get_in(["title"])
        question_type = question |> get_in(["question_type"])

        case correct_answer_validation(answers, question_type) do
          false ->
            {:error, "#{title} must have least 1 correct answers"}

          _ ->
            {:ok, title}
        end

        description_matching_cast(question)
      end)

    {errors, valid} =
      Enum.reduce(result, {[], []}, fn
        {:error, error_msg}, {errors_acc, valid_acc} ->
          {[error_msg | errors_acc], valid_acc}

        {:ok, ok_msg}, {errors_acc, valid_acc} ->
          {errors_acc, [ok_msg | valid_acc]}
      end)

    if Enum.empty?(errors) do
      {:ok, valid}
    else
      {:error, errors}
    end
  end

  defp correct_answer_validation(answers, question_type)
       when question_type in ~w(true_false multiple_choice) do
    Enum.any?(answers, fn answer -> answer |> get_in(["correct_answer"]) == true end)
  end

  defp correct_answer_validation(_, _), do: true

  defp description_matching_cast(
         %{
           "description" => description,
           "question_type" => question_type
         } = question
       )
       when question_type in ~w(matching) do
    case Solid.parse(description) do
      {:ok, _} ->
        valid_answers_variables_cast(question)

      {:error, error} ->
        {:error, error.message}
    end
  end

  defp description_matching_cast(_), do: {:ok, ""}

  def valid_answers_variables_cast(
        %{"title" => title, "answers" => answers, "description" => text} = _question
      ) do
    matches = Regex.scan(~r/{{(\w+)}}/, text)
    variable_names = Enum.map(matches, fn [_, match] -> match end)

    with true <- length(answers) == length(variable_names),
         :ok <- valid_answers_exist_variables(variable_names, answers) do
      {:ok, title}
    else
      _ ->
        {:error, "#{title} does not have the correct answers"}
    end
  end

  defp valid_answers_exist_variables(variable_names, answers) do
    description_variables = variable_names |> Enum.sort()
    answers_variables = answers |> Enum.map(fn x -> x["description"] end) |> Enum.sort()

    if description_variables == answers_variables do
      :ok
    else
      :error
    end
  end

  defp create_activity(topic, params, valid_params) do
    Task.async(fn ->
      activity_type = valid_params |> get_in([:activity_type])

      create_valid_params = %{
        name: valid_params |> get_in([:name]),
        topic_id: topic.uuid,
        activity_type: activity_type,
        feedback: valid_params |> get_in([:feedback]),
        enabled: valid_params |> get_in([:enabled]) || false,
        start_date: valid_params |> get_in([:start_date]),
        end_date: valid_params |> get_in([:end_date]),
        max_attempts: valid_params |> get_in([:max_attempts]) || 1,
        grade_pass: valid_params |> get_in([:grade_pass]) || 100
      }

      case activity_type do
        "resource" ->
          resource = params |> get_in(["resource"])
          params = create_valid_params |> Map.merge(%{resource: resource})
          Activity.create_with_resource(params)

        _ ->
          params =
            create_valid_params |> Map.merge(%{questions: valid_params |> get_in([:questions])})

          Activity.create_with_quiz(params)
      end
    end)
    |> Task.await()
  end

  def require_answers?(_value, data), do: data.question_type != "open_answer"

  def require_question_description?(_value, data), do: data.question_type in ~w[missing]
end

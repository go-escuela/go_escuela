defmodule Web.Activities.ActivitiesJSON do
  @doc """
  Renders users
  """
  alias Core.Schema.Activity

  def create(%{activity: activity}) do
    case activity |> Activity.resource?() do
      true ->
        %{
          data: data(activity)
        }

      # quiz activity
      _ ->
        %{
          data:
            data(activity)
            |> Map.merge(%{
              questions: for(question <- activity.questions, do: question_data(question))
            })
        }
    end
  end

  defp data(%Activity{} = activity) do
    %{
      id: activity.uuid,
      name: activity.name,
      enabled: activity.enabled
    }
  end

  defp question_data(question) do
    %{
      id: question.uuid,
      title: question.title,
      mark: question.mark,
      feedback: question.mark,
      question_type: question.question_type
    }
    |> Map.merge(%{answers: for(answer <- question.answers, do: answer_data(answer))})
  end

  defp answer_data(answer) do
    %{
      id: answer.uuid,
      description: answer.description,
      feedback: answer.feedback,
      correct_answer: answer.correct_answer
    }
  end
end

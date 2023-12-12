defmodule Web.Onboarding.InstitutionInfoJSON do
  @doc """
  Renders institution info
  """

  def show(%{institution_info: institution_info}) do
    %{data: %{name: institution_info.name, created_at: institution_info.inserted_at}}
  end

  def create(%{}) do
    %{data: %{}}
  end

  def update(%{}) do
    %{data: %{}}
  end
end

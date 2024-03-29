defmodule Web.Onboarding.InstitutionInfoJSON do
  @doc """
  Renders institution info
  """

  def show(%{institution_info: institution_info}) do
    %{data: %{name: institution_info.name}}
  end
end

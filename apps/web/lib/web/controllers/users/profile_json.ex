defmodule Web.Users.ProfileJSON do
  @doc """
  Renders profile
  """
  def show(%{data: data}) do
    data(data)
  end

  def update(%{data: data}) do
    data(data)
  end

  defp data(user) do
    %{name: user.full_name, email: user.email}
  end
end

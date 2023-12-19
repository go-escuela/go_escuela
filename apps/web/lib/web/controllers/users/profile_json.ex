defmodule Web.Users.ProfileJSON do
  @doc """
  Renders users
  """
  def show(%{data: data}) do
    %{
      email: data.email,
      name: data.full_name
    }
  end
end

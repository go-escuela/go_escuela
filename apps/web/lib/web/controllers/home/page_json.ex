defmodule Web.Home.PageJSON do
  @doc """
  Renders a single user.
  """
  def show(%{status: status}) do
    %{status: status}
  end
end

defmodule Web.Auth.SessionJSON do
  @doc """
  Renders a single user.
  """
  def create(%{account: account, token: token}) do
    %{email: account.email, token: token}
  end
end

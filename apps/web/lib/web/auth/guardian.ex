defmodule Web.Auth.Guardian do
  @moduledoc """
  module for check user credentials using Guardian dep
  """
  use Guardian, otp_app: :web
  alias GoEscuelaLms.Core.Schema.User

  def subject_for_token(%{uuid: uuid}, _claims) do
    sub = to_string(uuid)
    {:ok, sub}
  end

  def subject_for_token(_, _) do
    {:error, :no_id_provided}
  end

  def resource_from_claims(%{"sub" => uuid}) do
    case User.find(uuid) do
      nil -> {:error, :not_found}
      resource -> {:ok, resource}
    end
  end

  def resource_from_claims(_claims) do
    {:error, :no_id_provided}
  end

  def authenticate(email, password) do
    with {:ok, account} <- User.get_account_by_email(email),
         true <- validate_password(password, account.password_hash) do
      create_token(account)
    else
      _ ->
        {:error, :unauthorized}
    end
  end

  defp validate_password(password, password_hash) do
    Bcrypt.verify_pass(password, password_hash)
  end

  defp create_token(account) do
    {:ok, token, _claims} = encode_and_sign(account)
    {:ok, account, token}
  end
end
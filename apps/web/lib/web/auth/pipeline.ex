defmodule Web.Auth.Pipeline do
  @moduledoc """
  module collect various plugs for authentication
  """

  use Guardian.Plug.Pipeline,
    otp_app: :web,
    module: Web.Auth.Guardian,
    error_handler: Web.Auth.GuardianErrorHandler

  plug Guardian.Plug.VerifySession
  plug Guardian.Plug.VerifyHeader
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end

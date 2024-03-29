defmodule Web.Onboarding.InstitutionInfoController do
  use Web, :controller

  action_fallback Web.FallbackController

  import Web.Auth.AuthorizedPlug

  alias GoEscuelaLms.Core.Schema.InstitutionInfo

  plug :organizer_authorized when action in [:show]

  def show(conn, _params) do
    institution_info = InstitutionInfo.get!()

    render(conn, :show, %{institution_info: institution_info})
  end
end

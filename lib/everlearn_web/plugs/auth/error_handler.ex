defmodule Everlearn.Auth.ErrorHandler do
  import Plug.Conn
  use EverlearnWeb, :controller

  def auth_error(conn, {_type, _reason}, claims) do
    # called with conn, {:unauthenticated, :unauthenticated} and [claims: %{"typ" => "user-access"}]
    case conn.private.phoenix_format do
      "json" ->
        conn
          |> put_status(401)
          |> render(EverlearnWeb.ErrorView, "401.json")
      "html" ->
        conn
          |> put_flash(:error, "You must be logged in to access that part.")
          |> redirect(to: "/")
    end
  end

end

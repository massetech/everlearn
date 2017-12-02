defmodule Everlearn.Auth.ErrorHandler do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def auth_error(conn, {type, reason}, _opts) do
    conn
    |> put_flash(:error, "You must be logged in to access that part.")
    |> redirect(to: "/")
  end

end

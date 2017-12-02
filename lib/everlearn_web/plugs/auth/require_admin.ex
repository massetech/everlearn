defmodule Everlearn.Plugs.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  alias Everlearn.Members
  alias Everlearn.Router.Helpers, as: Routes

  def init(_params) do
  end

  def call(conn, _params) do
    case Members.admin_user?(conn.assigns[:current_user]) do
      true ->
        conn
      false ->
        conn
        |> put_flash(:error, "You cant access to this part.")
        |> redirect(to: "/")
        # |> redirect(to: Routes.root_path(conn, :welcome))
        |> halt()
    end
  end
end

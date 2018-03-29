defmodule EverlearnWeb.AuthController do
  use EverlearnWeb, :controller
  alias Ueberauth.Strategy.Helpers
  alias Everlearn.{Members}
  alias Everlearn.Auth.{Guardian}

  plug Ueberauth

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
      |> Guardian.Plug.sign_out()
      |> put_flash(:info, "You are logged out.")
      |> IO.inspect()
      |> redirect(to: root_path(conn, :welcome))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
      |> put_flash(:error, "Failed to authenticate.")
      |> redirect(to: root_path(conn, :welcome))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case Members.sign_in_user(auth) do
      {:created, user} ->
        conn
          |> Guardian.Plug.sign_in(user, %{"typ" => "user-access"})
          |> put_flash(:info, "Welcome, you are logged in !")
          |> redirect(to: root_path(conn, :welcome))
      {:updated, user} ->
        conn
          |> Guardian.Plug.sign_in(user, %{"typ" => "user-access"})
          |> put_flash(:info, "Welcome back #{user.nickname} !")
          |> redirect(to: root_path(conn, :welcome))
      {:error, changeset} ->
        conn
          |> put_flash(:error, "Sorry couldn't sign you in as #{changeset.email}.")
          |> redirect(to: root_path(conn, :welcome))
    end
  end
end

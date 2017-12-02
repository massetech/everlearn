defmodule EverlearnWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use EverlearnWeb, :controller
  alias Ueberauth.Strategy.Helpers
  alias Everlearn.{Members}
  alias Everlearn.Members.{User}
  alias Everlearn.Auth.{Guardian}
  plug Ueberauth

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    #|> configure_session(drop: true)
    # |> clear_session()
    |> Guardian.Plug.sign_out()
    #|> put_status(200)
    |> put_flash(:info, "You have been logged out.")
    |> redirect(to: root_path(conn, :welcome))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    #|> put_status(401)
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: root_path(conn, :welcome))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    # IO.inspect(auth)
    case Members.signin(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome, your signed in !")
        |> Guardian.Plug.sign_in(user)
        # |> put_session(:user_id, user.id)
        |> redirect(to: root_path(conn, :welcome))
      {:updated, user} ->
        conn
        |> put_flash(:info, "Welcome back #{user.nickname}, your are signed in !")
        |> Guardian.Plug.sign_in(user)
        # |> put_session(:user_id, user.id)
        |> redirect(to: root_path(conn, :welcome))
      {:error, reason} ->
        IO.inspect(reason)
        conn
        |> put_flash(:error, "Sorry couldn't sign you in fro Google.")
        |> redirect(to: root_path(conn, :welcome))
    end
  end

end

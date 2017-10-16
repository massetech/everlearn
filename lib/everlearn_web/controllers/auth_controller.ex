defmodule EverlearnWeb.AuthController do
  @moduledoc """
  Auth controller responsible for handling Ueberauth responses
  """

  use EverlearnWeb, :controller
  alias Ueberauth.Strategy.Helpers
  alias Everlearn.Members
  alias Everlearn.Members.{User}
  plug Ueberauth

  def request(conn, _params) do
    render(conn, "request.html", callback_url: Helpers.callback_url(conn))
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> put_flash(:info, "You have been logged out.")
    |> IO.inspect()
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    IO.inspect(auth)
    case Everlearn.Members.signin(auth) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "Welcome, your signed in !")
        |> put_session(:user_id, user.id)
        |> redirect(to: "/")
      {:updated, user} ->
        conn
        |> put_flash(:info, "Welcome back #{user.nickname}, your are signed in !")
        |> put_session(:user_id, user.id)
        |> redirect(to: "/")
      {:error, reason} ->
        IO.inspect(reason)
        conn
        |> put_flash(:error, "Sorry couldn't sign you in.")
        |> redirect(to: "/")
    end
  end

end

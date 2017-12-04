defmodule EverlearnWeb.MainController do
  use EverlearnWeb, :controller

  def welcome(conn, _params) do
    conn
      |> render EverlearnWeb.PublicView, "welcome.html"
  end
end

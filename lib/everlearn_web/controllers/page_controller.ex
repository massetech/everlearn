defmodule EverlearnWeb.PageController do
  use EverlearnWeb, :controller

  def index(conn, _params) do
    conn
    |> put_flash(:info, "Welcome : info")
    |> put_flash(:success, "Welcome : success")
    |> put_flash(:error, "Welcome : error")
    |> render("index.html")
  end
end

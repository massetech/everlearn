defmodule EverlearnWeb.PageController do
  use EverlearnWeb, :controller

  def index(conn, _params) do
    conn
    |> put_flash(:info, "Welcome : info")
    |> put_flash(:error, "Welcome : error")
    render conn, "index.html"
  end
end

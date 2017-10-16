defmodule EverlearnWeb.PageController do
  use EverlearnWeb, :controller

  def index(conn, _params) do
    IO.inspect(conn)
    render conn, "index.html"
  end
end

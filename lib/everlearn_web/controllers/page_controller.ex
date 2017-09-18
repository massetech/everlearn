defmodule EverlearnWeb.PageController do
  use EverlearnWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end

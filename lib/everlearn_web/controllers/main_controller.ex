defmodule EverlearnWeb.MainController do
  use EverlearnWeb, :controller
  alias Everlearn.{Members, Slidebars}
  import PhoenixGon.Controller
  require Logger

  plug Everlearn.Plug.DisplayFlashes

  def welcome(conn, _params) do
    # conn
    # |> Guardian.Plug.current_resource()
    # |> IO.inspect()
    # conn
    # |> Guardian.Plug.current_claims()
    # |> IO.inspect()
    # conn
    # |> Guardian.Plug.current_token()
    # |> IO.inspect()
    conn
      |> render(EverlearnWeb.PublicView, "welcome.html")
  end

  def show_player(conn, _params) do
    # Logger.info("XXXX User ID XXXXX")
    # Logger.info("Conn: #{inspect(conn.assigns)}")
    content = Members.get_user_learning_data(conn.assigns.current_user.id)
    # Logger.info("Content: #{inspect(content)}")
    token = Guardian.Plug.current_token(conn)
    json_data = %{token: token, content: content}
      |> Poison.encode!()
    slidebars = content
      |> Slidebars.navbar_player()
    conn
      |> put_gon(json_data: json_data, api_url: Application.get_env(:everlearn, :api_url))
      |> render(EverlearnWeb.PublicView, "player.html", slidebars: slidebars)
  end

end

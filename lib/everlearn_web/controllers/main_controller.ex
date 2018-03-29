defmodule EverlearnWeb.MainController do
  use EverlearnWeb, :controller
  alias Everlearn.{Members, Slidebars}
  import PhoenixGon.Controller

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
      |> IO.inspect()
      |> render(EverlearnWeb.PublicView, "welcome.html")
  end

  def show_player(conn, _params) do
    content = Members.get_user_learning_data(conn.assigns.current_user.id)
    token = Guardian.Plug.current_token(conn)
    json_data = %{token: token, content: content}
      |> IO.inspect()
      |> Poison.encode!()
    slidebars = content
      |> Slidebars.navbar_player()
    conn
      |> put_gon(json_data: json_data)
      |> render(EverlearnWeb.PublicView, "player.html", slidebars: slidebars)
  end

end

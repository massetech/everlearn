defmodule Everlearn.Plugs.SearchRummage do
  import Plug.Conn
  # import Phoenix.Controller
  #
  # alias Everlearn.Repo
  # alias Everlearn.Members
  # alias Everlearn.Members.User

  def init(_params) do
  end

  def call(conn, params) do
    # %{"search" => search_params} = params \\ nil
    case params do
      nil ->
        IO.puts("no params :( ++++++++)")
        conn
      %{"search" => search_params} = params ->
        IO.puts("++++++")
        IO.inspect(search_params)
        conn
    end
    # user_id = get_session(conn, :user_id)
    # cond do
    #   user = user_id && Repo.get(User, user_id) ->
    #     assign(conn, :user, user)
    #   true ->
    #     assign(conn, :user, nil)
    # end
  end

end

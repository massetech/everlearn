defmodule Everlearn.Auth.CurrentUser do
  import Plug.Conn
  import Guardian.Plug

  alias Everlearn.Repo
  alias Everlearn.Members.User

  def init(opts), do: opts
  def call(conn, _opts) do
    # IO.puts("+Current User+")
    # conn
    # |> IO.inspect()
    cond do
      # ressource = current_resource(conn) ->
      ressource = Guardian.Plug.current_resource(conn) ->
        assign(conn, :current_user, Repo.get(User, ressource.id))
      true ->
        assign(conn, :current_user, nil)
    end

  end
end

defmodule EverlearnWeb.MemoryController do
  use EverlearnWeb, :controller
  alias Everlearn.Members

  plug Everlearn.Plug.DisplayFlashes
  plug :fetch_navtitle_index when action in [:index]

  defp fetch_navtitle_index(conn, _params) do
    conn
    |> assign(:nav_title, "Memorys")
  end

  def index(conn, _params) do
    memorys = Members.list_memorys()
    render(conn, "index.html", memorys: memorys)
  end

  def delete(conn, %{"id" => id}) do
    memory = Members.get_memory!(id)
    {:ok, _memory} = Members.delete_memory(memory)

    conn
    |> put_flash(:info, "Memory deleted successfully.")
    |> redirect(to: memory_path(conn, :index))
  end
end

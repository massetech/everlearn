defmodule EverlearnWeb.UserController do
  use EverlearnWeb, :controller
  alias Everlearn.Members

  plug Everlearn.Plug.DisplayFlashes
  plug :fetch_navtitle_index when action in [:index]
  plug :fetch_navtitle_other when action in [:edit, :update]
  plug :load_select when action in [:edit, :update]

  defp fetch_navtitle_index(conn, _params) do
    conn
    |> assign(:nav_title, "Users")
    |> assign(:nav_new_path, user_path(conn, :new))
  end
  defp fetch_navtitle_other(conn, _params) do
    conn
    |> assign(:nav_title, "User")
    |> assign(:nav_index_path, user_path(conn, :index))
  end
  defp load_select(conn, _params) do
    conn
      |> assign(:roles, Everlearn.Members.User.role_select_btn())
  end

  def index(conn, _params) do
    users = Members.list_users()
    render(conn, "index.html", users: users)
  end

  def edit(conn, %{"id" => id}) do
    user = Members.get_user!(id)
    changeset = Members.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Members.get_user!(id)

    case Members.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Members.get_user!(id)
    {:ok, _user} = Members.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end
end

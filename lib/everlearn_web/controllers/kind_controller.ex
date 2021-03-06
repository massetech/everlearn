defmodule EverlearnWeb.KindController do
  use EverlearnWeb, :controller
  alias Everlearn.Contents
  alias Everlearn.Contents.Kind

  plug Everlearn.Plug.DisplayFlashes
  plug :fetch_navtitle_index when action in [:index]
  plug :fetch_navtitle_other when action in [:new, :show, :edit, :create, :update]

  defp fetch_navtitle_index(conn, _params) do
    conn
    |> assign(:nav_title, "Kinds")
    |> assign(:nav_new_path, kind_path(conn, :new))
  end

  defp fetch_navtitle_other(conn, _params) do
    conn
    |> assign(:nav_title, "Kind")
    |> assign(:nav_index_path, kind_path(conn, :index))
  end

  def index(conn, _params) do
    kinds = Contents.list_kinds()
    IO.inspect(conn)
    render(conn, "index.html", kinds: kinds)
  end

  def new(conn, _params) do
    changeset = Contents.change_kind(%Kind{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"kind" => kind_params}) do
    case Contents.create_kind(kind_params) do
      {:ok, _kind} ->
        conn
        |> put_flash(:info, "Kind created successfully.")
        |> redirect(to: kind_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    kind = Contents.get_kind!(id)
    changeset = Contents.change_kind(kind)
    render(conn, "edit.html", kind: kind, changeset: changeset)
  end

  def update(conn, %{"id" => id, "kind" => kind_params}) do
    kind = Contents.get_kind!(id)

    case Contents.update_kind(kind, kind_params) do
      {:ok, _kind} ->
        conn
        |> put_flash(:info, "Kind updated successfully.")
        |> redirect(to: kind_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", kind: kind, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    kind = Contents.get_kind!(id)
    {:ok, _kind} = Contents.delete_kind(kind)

    conn
    |> put_flash(:info, "Kind deleted successfully.")
    |> redirect(to: kind_path(conn, :index))
  end
end

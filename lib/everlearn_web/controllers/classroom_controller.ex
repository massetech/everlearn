defmodule EverlearnWeb.ClassroomController do
  use EverlearnWeb, :controller
  alias Everlearn.Contents
  alias Everlearn.Contents.Classroom
  
  plug Everlearn.Plug.DisplayFlashes
  plug :fetch_navtitle_index when action in [:index]
  plug :fetch_navtitle_other when action in [:new, :show, :edit, :create, :update]

  defp fetch_navtitle_index(conn, _params) do
    conn
    |> assign(:nav_title, "Classrooms")
    |> assign(:nav_new_path, classroom_path(conn, :new))
  end

  defp fetch_navtitle_other(conn, _params) do
    conn
    |> assign(:nav_title, "Classroom")
    |> assign(:nav_index_path, classroom_path(conn, :index))
  end

  def index(conn, _params) do
    classrooms = Contents.list_classrooms()
    render(conn, "index.html", classrooms: classrooms)
  end

  def new(conn, _params) do
    changeset = Contents.change_classroom(%Classroom{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"classroom" => classroom_params}) do
    case Contents.create_classroom(classroom_params) do
      {:ok, _classroom} ->
        conn
        |> put_flash(:info, "Classroom created successfully.")
        |> redirect(to: classroom_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # def show(conn, %{"id" => id}) do
  #   classroom = Contents.get_classroom!(id)
  #   render(conn, "show.html", classroom: classroom)
  # end

  def edit(conn, %{"id" => id}) do
    classroom = Contents.get_classroom!(id)
    changeset = Contents.change_classroom(classroom)
    render(conn, "edit.html", classroom: classroom, changeset: changeset)
  end

  def update(conn, %{"id" => id, "classroom" => classroom_params}) do
    classroom = Contents.get_classroom!(id)

    case Contents.update_classroom(classroom, classroom_params) do
      {:ok, _classroom} ->
        conn
        |> put_flash(:info, "Classroom updated successfully.")
        |> redirect(to: classroom_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", classroom: classroom, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    classroom = Contents.get_classroom!(id)
    {:ok, _classroom} = Contents.delete_classroom(classroom)

    conn
    |> put_flash(:info, "Classroom deleted successfully.")
    |> redirect(to: classroom_path(conn, :index))
  end
end

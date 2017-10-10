defmodule EverlearnWeb.ClassroomController do
  use EverlearnWeb, :controller

  alias Everlearn.Classrooms
  alias Everlearn.Classrooms.Classroom

  def index(conn, _params) do
    classrooms = Classrooms.list_classrooms()
    render(conn, "index.html", classrooms: classrooms)
  end

  def new(conn, _params) do
    changeset = Classrooms.change_classroom(%Classroom{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"classroom" => classroom_params}) do
    case Classrooms.create_classroom(classroom_params) do
      {:ok, _classroom} ->
        conn
        |> put_flash(:info, "Classroom created successfully.")
        |> redirect(to: classroom_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # def show(conn, %{"id" => id}) do
  #   classroom = Classrooms.get_classroom!(id)
  #   render(conn, "show.html", classroom: classroom)
  # end

  def edit(conn, %{"id" => id}) do
    classroom = Classrooms.get_classroom!(id)
    changeset = Classrooms.change_classroom(classroom)
    render(conn, "edit.html", classroom: classroom, changeset: changeset)
  end

  def update(conn, %{"id" => id, "classroom" => classroom_params}) do
    classroom = Classrooms.get_classroom!(id)

    case Classrooms.update_classroom(classroom, classroom_params) do
      {:ok, _classroom} ->
        conn
        |> put_flash(:info, "Classroom updated successfully.")
        |> redirect(to: classroom_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", classroom: classroom, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    classroom = Classrooms.get_classroom!(id)
    {:ok, _classroom} = Classrooms.delete_classroom(classroom)

    conn
    |> put_flash(:info, "Classroom deleted successfully.")
    |> redirect(to: classroom_path(conn, :index))
  end
end

defmodule EverlearnWeb.MemoryController do
  use EverlearnWeb, :controller

  alias Everlearn.Members
  alias Everlearn.Members.Memory

  def index(conn, _params) do
    memorys = Members.list_memorys()
    render(conn, "index.html", memorys: memorys)
  end

  def new(conn, _params) do
    changeset = Members.change_memory(%Memory{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"memory" => memory_params}) do
    case Members.create_memory(memory_params) do
      {:ok, memory} ->
        conn
        |> put_flash(:info, "Memory created successfully.")
        |> redirect(to: memory_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    memory = Members.get_memory!(id)
    render(conn, "show.html", memory: memory)
  end

  def edit(conn, %{"id" => id}) do
    memory = Members.get_memory!(id)
    changeset = Members.change_memory(memory)
    render(conn, "edit.html", memory: memory, changeset: changeset)
  end

  def update(conn, %{"id" => id, "memory" => memory_params}) do
    memory = Members.get_memory!(id)

    case Members.update_memory(memory, memory_params) do
      {:ok, memory} ->
        conn
        |> put_flash(:info, "Memory updated successfully.")
        |> redirect(to: memory_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", memory: memory, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    memory = Members.get_memory!(id)
    {:ok, _memory} = Members.delete_memory(memory)

    conn
    |> put_flash(:info, "Memory deleted successfully.")
    |> redirect(to: memory_path(conn, :index))
  end
end

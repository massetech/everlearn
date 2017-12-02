defmodule EverlearnWeb.ItemController do
  use EverlearnWeb, :controller
  use Rummage.Phoenix.Controller

  alias Everlearn.{Contents, CustomSelects, Imports}
  alias Everlearn.Contents.{Item, Card}
  plug :load_select when action in [:index, :new, :create, :edit, :update, :index]

  defp load_select(conn, _params) do
    conn
    |> assign(:classrooms, Contents.classroom_select_btn())
    |> assign(:topics, Contents.topic_select_btn())
    |> assign(:levels, Contents.pack_level_select_btn())
    |> assign(:kinds, Contents.kind_select_btn())
    |> assign(:active, CustomSelects.status_select_btn())
  end

  def index(conn, params) do
    {items, rummage} = Contents.list_items(params)
    changeset = Contents.change_item(%Item{})
    render(conn, "index.html", items: items, changeset: changeset, rummage: rummage)
  end

  def import(conn, %{"item" => item_params}) do
    topic_id = item_params["topic_id"]
    msg = item_params["file"].path
      |> Imports.import("Contents", "item", Contents.item_import_fields, {:topic_id, topic_id})
      |> IO.inspect()
      |> Imports.flash_answers()
    conn
      |> put_flash(elem(msg, 0), elem(msg, 1))
      |> redirect(to: item_path(conn, :index))
  end

  def new(conn, _params) do
    changeset = Contents.change_item(%Item{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item" => item_params}) do
    case Contents.create_item(item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "Item created successfully.")
        |> redirect(to: item_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Contents.get_item!(id)
    render(conn, "show.html", item: item)
  end

  def edit(conn, %{"id" => id}) do
    item = Contents.get_item!(id)
    changeset = Contents.change_item(item)
    render(conn, "edit.html", item: item, changeset: changeset)
  end

  def update(conn, %{"id" => id, "item" => item_params}) do
    item = Contents.get_item!(id)

    case Contents.update_item(item, item_params) do
      {:ok, item} ->
        conn
        |> put_flash(:info, "Item updated successfully.")
        |> redirect(to: item_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", item: item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Contents.get_item!(id)
    {:ok, _item} = Contents.delete_item(item)

    conn
    |> put_flash(:info, "Item deleted successfully.")
    |> redirect(to: item_path(conn, :index))
  end
end

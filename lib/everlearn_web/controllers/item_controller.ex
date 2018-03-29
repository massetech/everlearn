defmodule EverlearnWeb.ItemController do
  use EverlearnWeb, :controller
  use Rummage.Phoenix.Controller
  alias Everlearn.{Contents, CustomSelects, Imports}
  alias Everlearn.Contents.{Item}

  plug Everlearn.Plug.DisplayFlashes
  plug :load_select when action in [:index, :show, :new, :create, :edit, :update]
  plug :fetch_navtitle_index when action in [:index]
  plug :fetch_navtitle_other when action in [:new, :show, :edit, :create, :update]

  defp fetch_navtitle_index(conn, _params) do
    conn
    |> assign(:nav_title, "Items")
    |> assign(:nav_new_path, item_path(conn, :new))
  end

  defp fetch_navtitle_other(conn, _params) do
    conn
    |> assign(:nav_title, "Item")
    |> assign(:nav_index_path, item_path(conn, :index))
  end

  defp load_select(conn, _params) do
    conn
      |> assign(:classrooms, Contents.classroom_select_btn())
      |> assign(:topics, Contents.topic_select_btn())
      |> assign(:levels, Contents.pack_level_select_btn())
      |> assign(:kinds, Contents.kind_select_btn())
      |> assign(:active, CustomSelects.status_select_btn())
      |> assign(:languages, Everlearn.Members.language_select_btn())
  end

  def index(conn, params) do
    {items, rummage} = Contents.list_items(params)
    changeset = Contents.change_item(%Item{})
    conn
      |> assign(:import_action, import_items_path(conn, :item))
      |> render("index.html", items: items, changeset: changeset, rummage: rummage)
  end

  def new(conn, _params) do
    changeset = Contents.change_item(%Item{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"item" => item_params}) do
    IO.puts "test OK"
    case Contents.create_item(item_params) do
      {:ok, _item} ->
        conn
        |> put_flash(:info, "Item created successfully.")
        |> redirect(to: item_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    item = Contents.get_item!(id)
    # cards = Contents.get_cards_from_item(item)
    changeset = Contents.change_item(item)
    render conn, "show.html", item: item, changeset: changeset
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
        Contents.clean_existing_packitems(item)
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

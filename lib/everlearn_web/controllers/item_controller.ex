defmodule EverlearnWeb.ItemController do
  use EverlearnWeb, :controller
  use Rummage.Phoenix.Controller

  alias Everlearn.Contents
  alias Everlearn.Contents.{Item, Card}
  plug :load_select when action in [:new, :create, :edit, :update, :index]

  defp load_select(conn, _params) do
    conn
    |> assign(:topics, Contents.topic_select_btn())
    |> assign(:levels, Contents.pack_level_select_btn())
    |> assign(:groups, Contents.item_group_select_btn())
    # |> assign(:status, ["active", "inactive"])
  end

  def index(conn, params) do
    {query, rummage} = Item
    |> Item.rummage(params["rummage"])
    items = Contents.list_items(query)
    render(conn, "index.html", items: items, rummage: rummage)
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

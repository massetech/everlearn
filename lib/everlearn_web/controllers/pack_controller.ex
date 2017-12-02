defmodule EverlearnWeb.PackController do
  use EverlearnWeb, :controller
  use Drab.Controller

  alias Everlearn.{Contents, Members, CustomSelects}
  alias Everlearn.Contents.{Pack, Item}

  plug :load_select when action in [:new, :create, :edit, :update, :index, :user_index]

  defp load_select(conn, _params) do
    conn
    |> assign(:classrooms, Contents.classroom_select_btn())
    |> assign(:levels, Contents.pack_level_select_btn())
    |> assign(:active, CustomSelects.status_select_btn())
    |> assign(:languages, Members.language_select_btn())
  end

  def index(conn, params) do
    {packs, rummage} = params
    |> Map.put_new("user_id", conn.assigns.current_user.id)
    |> Contents.list_packs()
    render conn, "admin_index.html", packs: packs, rummage: @rummage
  end

  def user_index(conn, params) do
    # Filter on active packs only for users if no search params yet
    {packs, rummage} = params
    |> Map.put_new("search", %{"active" => true})
    |> Contents.list_packs()
    render conn, "user_index.html", packs: packs, rummage: @rummage
  end

  def new(conn, _params) do
    changeset = Contents.change_pack(%Pack{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pack" => pack_params}) do
    case Contents.create_pack(pack_params) do
      {:ok, pack} ->
        conn
        |> put_flash(:info, "Pack created successfully.")
        |> redirect(to: pack_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> load_select("")
        |> put_flash(:error, "Please check the errors below.")
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    # {query, rummage} = Item
    # |> Item.rummage()
    pack = Contents.get_pack!(id)
    items = Contents.list_eligible_items(pack)
    render conn, "show.html", pack: pack, items: items
  end

  def edit(conn, %{"id" => id}) do
    pack = Contents.get_pack!(id)
    changeset = Contents.change_pack(pack)
    render(conn, "edit.html", pack: pack, changeset: changeset)
  end

  def update(conn, %{"id" => id, "pack" => pack_params}) do
    pack = Contents.get_pack!(id)

    case Contents.update_pack(pack, pack_params) do
      {:ok, pack} ->
        conn
        |> put_flash(:info, "Pack updated successfully.")
        |> redirect(to: pack_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", pack: pack, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    pack = Contents.get_pack!(id)
    {:ok, _pack} = Contents.delete_pack(pack)

    conn
    |> put_flash(:info, "Pack deleted successfully.")
    |> redirect(to: pack_path(conn, :index))
  end
end

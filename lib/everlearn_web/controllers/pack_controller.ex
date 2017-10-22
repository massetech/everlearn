defmodule EverlearnWeb.PackController do
  use EverlearnWeb, :controller
  use Drab.Controller
  use Rummage.Phoenix.Controller

  alias Everlearn.Contents
  alias Everlearn.Contents.Pack
  plug :load_select when action in [:new, :edit]

  defp load_select(conn, _params) do
    conn
    |> assign(:classrooms, Contents.classroom_select_btn())
    |> assign(:levels, Contents.pack_level_select_btn())
  end

  def index(conn, params) do
    {query, rummage} = Pack
    |> Pack.rummage(params["rummage"])
    packs = Contents.list_packs(query)
    render conn, "index.html", packs: packs, rummage: rummage
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
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    pack = Contents.get_pack!(id)
    items = Contents.list_items
    render conn, "show.html", pack: pack, welcome_text: "Welcome to Drab!", items: items, button: 'ici'
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

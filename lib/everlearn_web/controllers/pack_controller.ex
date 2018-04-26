defmodule EverlearnWeb.PackController do
  use EverlearnWeb, :controller
  use Rummage.Phoenix.Controller
  use Drab.Controller
  alias Everlearn.{Contents, Members, CustomSelects}
  alias Everlearn.Contents.{Pack}
  alias Everlearn.QueryFilter

  plug Everlearn.Plug.DisplayFlashes
  plug :load_select when action in [:index, :public_index, :show, :new, :edit]
  plug :fetch_navtitle_index when action in [:index]
  plug :fetch_navtitle_other when action in [:new, :show, :edit, :create, :update]

  defp fetch_navtitle_index(conn, _params) do
    conn
      |> assign(:nav_title, "Packs")
      |> assign(:nav_new_path, pack_path(conn, :new))
  end

  defp fetch_navtitle_other(conn, _params) do
    conn
      |> assign(:nav_title, "Pack")
      |> assign(:nav_index_path, pack_path(conn, :index))
  end

  defp load_select(conn, _params) do
    conn
      |> assign(:classrooms, Contents.classroom_select_btn())
      |> assign(:levels, Contents.pack_level_select_btn())
      |> assign(:active, CustomSelects.status_select_btn())
      |> assign(:packitemlinks, CustomSelects.packitem_link_btn())
      |> assign(:languages, Members.languages_select_btn())
      |> assign(:kinds, Contents.kind_select_btn())
      |> assign(:topics, Contents.topic_select_btn())
  end

  def index(conn, params) do
    {packs, rummage} = params
      |> Contents.list_packs()
    changeset = Contents.change_pack(%Pack{})
    render(conn, "index.html", packs: packs, rummage: rummage, changeset: changeset)
  end

  def public_index(conn, params) do
    student_lg_id = params["search"]["student_lg_id"] || conn.assigns.current_user.language_id
    teacher_lg_id = params["search"]["teacher_lg_id"] || student_lg_id
    {packs, rummage} = params
      # Add student_lg_id to params if none was provided (1st time page loading)
      |> Map.put_new("search", %{"student_lg_id" => student_lg_id, "teacher_lg_id" => teacher_lg_id})
      |> Contents.list_public_packs(conn.assigns.current_user.id)
    changeset = Contents.change_pack(%Pack{})
    conn
      |> assign(:nav_title, "My packs")
      |> assign(:packs, packs)
      |> assign(:rummage, rummage)
      |> assign(:query_languages, %{student_lg_id: student_lg_id, teacher_lg_id: teacher_lg_id})
      |> render(EverlearnWeb.PublicView, "pack_index.html", changeset: changeset)
  end

  def show(conn, params) do
    {pack, items, rummage} = Contents.list_items_eligible_to_pack(params)
    IO.inspect(List.first(items))
    conn
      |> render("show.html", pack: pack, items: items, rummage: rummage)
  end

  def new(conn, _params) do
    changeset = Contents.change_pack(%Pack{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pack" => pack_params}) do
    case Contents.create_pack(pack_params) do
      {:ok, _pack} ->
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

  def edit(conn, %{"id" => id}) do
    pack = Contents.get_pack!(id)
    languages = Members.list_pack_languages(pack.id)
    changeset = Contents.change_pack(pack)
    render(conn, "edit.html", pack: pack, changeset: changeset, languages: languages)
  end

  def update(conn, %{"id" => id, "pack" => pack_params}) do
    pack = Contents.get_pack!(id)

    case Contents.update_pack(pack, pack_params) do
      {:ok, _pack} ->
        conn
          |> put_flash(:info, "Pack updated successfully.")
          |> redirect(to: pack_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", pack: pack, changeset: changeset)
    end
  end

  def add_items_showed_from_pack(conn, params) do
    {pack, items, rummage} = Contents.list_items_eligible_to_pack(params)
    items
      |> Contents.add_items_to_pack(pack.id)
    search_params = QueryFilter.add_rummage_search(rummage)
    conn
      |> put_flash(:info, "#{Enum.count(items)} items were added to this pack.")
      |> redirect(to: pack_path(conn, :show, pack, rummage: rummage, search: search_params))
  end

  def remove_items_showed_from_pack(conn, params) do
    {pack, items, rummage} = Contents.list_items_eligible_to_pack(params)
    items
      |> Contents.remove_items_from_pack(pack.id)
    search_params = QueryFilter.add_rummage_search(rummage)
    conn
      |> put_flash(:info, "#{Enum.count(items)} items were removed from this pack.")
      |> redirect(to: pack_path(conn, :show, pack, rummage: rummage, search: search_params))
  end

  def delete(conn, %{"id" => id}) do
    pack = Contents.get_pack!(id)
    {:ok, _pack} = Contents.delete_pack(pack)
    conn
      |> put_flash(:info, "Pack deleted successfully.")
      |> redirect(to: pack_path(conn, :index))
  end
end

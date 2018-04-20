defmodule EverlearnWeb.MembershipController do
  use EverlearnWeb, :controller
  use Rummage.Phoenix.Controller
  alias Everlearn.{Members}
  alias Everlearn.Members.{Membership}

  plug Everlearn.Plug.DisplayFlashes
  plug :load_select when action in [:index]
  plug :fetch_navtitle_index when action in [:index]

  defp fetch_navtitle_index(conn, _params) do
    conn
    |> assign(:nav_title, "Memberships")
  end

  defp load_select(conn, _params) do
    conn
    |> assign(:languages, Members.languages_select_btn())
  end

  def index(conn, params) do
    {memberships, rummage} = Members.list_memberships(params)
    changeset = Members.change_membership(%Membership{})
    render(conn, "index.html", memberships: memberships, changeset: changeset, rummage: rummage)
  end

  def delete(conn, %{"id" => id}) do
    membership = Members.get_membership!(id)
    {:ok, _pack} = Members.delete_membership(membership)
    conn
    |> put_flash(:info, "Membership deleted successfully.")
    |> redirect(to: membership_path(conn, :index))
  end
end

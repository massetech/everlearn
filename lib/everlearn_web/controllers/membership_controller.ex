defmodule EverlearnWeb.MembershipController do
  use EverlearnWeb, :controller
  use Rummage.Phoenix.Controller

  alias Everlearn.{Members, CustomSelects}
  alias Everlearn.Members.{Membership}
  plug :load_select when action in [:index]

  defp load_select(conn, _params) do
    conn
      |> assign(:languages, Members.language_select_btn())
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

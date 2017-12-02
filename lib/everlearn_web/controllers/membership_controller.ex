defmodule EverlearnWeb.MembershipController do
  use EverlearnWeb, :controller

  alias Everlearn.Members

  def index(conn, params) do
    {memberships, rummage} = params
    |> Members.list_memberships()
    render conn, "index.html", memberships: memberships, rummage: @rummage
  end

  # def delete(conn, %{"id" => id}) do
  #   membership = Members.get_membership!(id)
  #   {:ok, _pack} = Members.delete_membership(membership)
  #
  #   conn
  #   |> put_flash(:info, "Pack deleted successfully.")
  #   |> redirect(to: pack_path(conn, :index))
  # end
end

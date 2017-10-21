defmodule EverlearnWeb.PackItemController do
  use EverlearnWeb, :controller
  use Drab.Controller

  def add_to_pack(conn, params) do
    changeset = Contents.change_pack_item(params)
    # case Contents.create_pack_item(changeset) do
    #   {:ok, item} ->
    #     # conn
    #     # |> put_flash(:info, "Item created successfully.")
    #     # |> redirect(to: item_path(conn, :index))
    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     # render(conn, "new.html", changeset: changeset)
    # end
  end

  def _remove_from_pack(conn, params) do

  end

end

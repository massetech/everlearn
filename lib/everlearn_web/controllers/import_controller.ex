defmodule EverlearnWeb.ImportController do
  use EverlearnWeb, :controller
  alias Everlearn.{Imports}

  def item(conn, %{"item" => %{"classroom_id" => classroom_id, "file" => file}}) do
    import_result = file.path
      |> Imports.import_items(%{classroom_id: classroom_id, active: true})
      |> Imports.analyse_and_log_results()
    conn
      |> put_flash(:success, "Your file was treated, please control your datas")
      |> redirect(to: item_path(conn, :index))
  end

  def card(conn, %{"card" => %{"language_id" => language_id, "file" => file}}) do
    import_result = file.path
      |> Imports.import_cards(%{language_id: language_id, active: true})
      |> Imports.analyse_and_log_results()
    conn
      |> put_flash(:success, "Your file was treated, please control your datas")
      |> redirect(to: card_path(conn, :index))
  end

  def packitem(conn, %{"pack_item" => %{"pack_id" => pack_id, "file" => file}}) do
    import_result = file.path
      |> Imports.import_packitems(%{pack_id: pack_id})
      |> Imports.analyse_and_log_results()
    conn
      |> put_flash(:success, "Your file was treated, please control your datas")
      |> redirect(to: pack_path(conn, :show, pack_id))
  end

end

defmodule EverlearnWeb.ImportController do
  use EverlearnWeb, :controller
  alias Everlearn.{Imports, Contents, Members}

  def item(conn, %{"item" => %{"classroom_id" => classroom_id, "pack_id"=> pack_id, "file" => file}} = params) do
    case control_import_item_params(pack_id, classroom_id, file.filename) do
      true ->
        import_result = file.path
          |> Imports.import_items(%{classroom_id: classroom_id, active: true, pack_id: pack_id})
          # |> Imports.analyse_and_log_results()
        conn
          |> put_flash(:success, "Your file was treated, please control your datas")
          |> redirect(to: item_path(conn, :index))
      false ->
        conn
          |> put_flash(:error, "Your file was not imported. Please control your parameters")
          |> redirect(to: item_path(conn, :index))
    end
  end

  defp control_import_item_params(pack_id, classroom_id, filename) do
    pack = Contents.get_pack!(pack_id)
    if to_string(pack.classroom_id) == classroom_id && filename =~ "item", do: true, else: false
  end

  def card(conn, %{"card" => %{"language_id" => language_id, "file" => file}}) do
    case control_import_card_params(language_id, file.filename) do
      true ->
        import_result = file.path
          |> Imports.import_cards(%{language_id: language_id, active: true})
          # |> Imports.analyse_and_log_results()
        conn
          |> put_flash(:success, "Your file was treated, please control your datas")
          |> redirect(to: card_path(conn, :index))
      false ->
        conn
          |> put_flash(:error, "Your file was not imported. Please control your parameters")
          |> redirect(to: card_path(conn, :index))
    end
  end

  defp control_import_card_params(language_id, filename) do
    language = Members.get_language!(language_id)
    if  filename =~ "card" &&  filename =~ language.iso2code, do: true, else: false
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

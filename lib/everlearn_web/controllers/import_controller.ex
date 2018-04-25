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

  # def card(conn, %{"card" => %{"language_id" => language_id, "file" => file}}) do
  #   results = file.path
  #     |> Imports.import("Contents", "card", %{language_id: language_id, active: true}, [:topic_id, :topic, :kind_id, :kind, :item_title, :level, :description])
  #   case results do
  #     {:ok, results} ->
  #       conn
  #         |> Imports.add_flash_answers(results)
  #         |> redirect(to: card_path(conn, :index))
  #     {:error, msg} ->
  #       conn
  #         |> put_flash(:error, msg)
  #         |> redirect(to: card_path(conn, :index))
  #   end
  # end

end

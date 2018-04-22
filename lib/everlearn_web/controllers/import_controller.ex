defmodule EverlearnWeb.ImportController do
  use EverlearnWeb, :controller
  alias Everlearn.{Imports}

  # defp report_import_result(import_result) do
  #   case import_result do
  #     {:ok, results} ->
  #       # IO.inspect(results)
  #       conn
  #         |> Imports.add_flash_answers(results)
  #         |> redirect(to: item_path(conn, :index))
  #     {:error, msg} ->
  #       conn
  #         |> put_flash(:error, msg)
  #         |> redirect(to: item_path(conn, :index))
  #   end
  # end

  def item(conn, %{"item" => %{"classroom_id" => classroom_id, "file" => file}}) do
    file.path
      |> Imports.import("Contents", "item", %{classroom_id: classroom_id, active: true}, [:kind, :topic, :question, :answer, :sound, :phonetic])
      |> Imports.analyse_and_log_resuts()
      # |> Enum.map(fn(import_result) -> report_import_result(import_result) end)
    conn
      # |> Imports.add_flash_answers(results)
      |> put_flash(:success, "Your file was treated, please control your datas")
      |> redirect(to: item_path(conn, :index))
  end

  def card(conn, %{"card" => %{"language_id" => language_id, "file" => file}}) do
    results = file.path
      |> Imports.import("Contents", "card", %{language_id: language_id, active: true}, [:topic_id, :topic, :kind_id, :kind, :item_title, :level, :description])
    case results do
      {:ok, results} ->
        # IO.inspect(results)
        conn
          |> Imports.add_flash_answers(results)
          |> redirect(to: card_path(conn, :index))
      {:error, msg} ->
        conn
          |> put_flash(:error, msg)
          |> redirect(to: card_path(conn, :index))
    end
  end

end

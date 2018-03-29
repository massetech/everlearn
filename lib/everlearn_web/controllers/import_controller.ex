defmodule EverlearnWeb.ImportController do
  use EverlearnWeb, :controller
  alias Everlearn.{Imports}

  def item(conn, %{"item" => %{"classroom_id" => classroom_id, "file" => file}}) do
    import_result = file.path
      |> Imports.import("Contents", "item", %{classroom_id: classroom_id})
    case import_result do
      {:ok, results} ->
        conn
          |> Imports.add_flash_answers(results)
          |> redirect(to: item_path(conn, :index))
      {:error, msg} ->
        conn
          |> put_flash(:error, msg)
          |> redirect(to: item_path(conn, :index))
    end
  end

  def card(conn, %{"card" => %{"file" => file}}) do
    import_result = file.path
      |> Imports.import("Contents", "card", %{}, [:item_title])
    case import_result do
      {:ok, results} ->
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

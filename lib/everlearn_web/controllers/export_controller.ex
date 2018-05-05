defmodule EverlearnWeb.ExportController do
  use EverlearnWeb, :controller
  alias Everlearn.Contents
  use Rummage.Phoenix.Controller

  def export_filtered_items(conn, params) do
    IO.puts("filtered")
    {items, rummage} = Contents.list_items(params)
    now = DateTime.utc_now()
    file_name = "Everlearn_filtered_items_export#{now.year}-#{now.month}-#{now.day}-#{now.hour}#{now.minute}#{now.second}.xlsx"
    conn
      |> put_resp_content_type("text/xlsx")
      |> put_resp_header("content-disposition", "attachment; filename=#{file_name}")
      |> render(EverlearnWeb.Reports.ItemView, "report.xlsx", %{items: items})
  end

  def export_all_items(conn, params) do
    items = Contents.export_all_items(params)
    now = DateTime.utc_now()
    classroom = List.first(items).classroom.title
    file_name = "Everlearn_all_items_#{classroom}_export#{now.year}-#{now.month}-#{now.day}-#{now.hour}#{now.minute}#{now.second}.xlsx"
    conn
      |> put_resp_content_type("text/xlsx")
      |> put_resp_header("content-disposition", "attachment; filename=#{file_name}")
      |> render(EverlearnWeb.Reports.AllItemsView, "report.xlsx", %{items: items})
  end

  def export_filtered_cards(conn, params) do
    {cards, rummage} = Contents.list_cards(params)
    now = DateTime.utc_now()
    file_name = "Everlearn_filtered_cards_export#{now.year}-#{now.month}-#{now.day}-#{now.hour}#{now.minute}#{now.second}.xlsx"
    conn
      |> put_resp_content_type("text/xlsx")
      |> put_resp_header("content-disposition", "attachment; filename=#{file_name}")
      |> render(EverlearnWeb.Reports.CardView, "report.xlsx", %{cards: cards})
  end

end

defmodule EverlearnWeb.ExportController do
  use EverlearnWeb, :controller
  alias Everlearn.Contents
  use Rummage.Phoenix.Controller

  def export_items(conn, params) do
    {items, rummage} = Contents.list_items(params)
    now = DateTime.utc_now()
    file_name = "Everlearn_items_export#{now.year}-#{now.month}-#{now.day}-#{now.hour}#{now.minute}#{now.second}.xlsx"
    conn
      |> put_resp_content_type("text/xlsx")
      |> put_resp_header("content-disposition", "attachment; filename=#{file_name}")
      |> render(EverlearnWeb.Reports.ItemView, "report.xlsx", %{items: items})
  end

  def export_cards(conn, params) do
    {cards, rummage} = Contents.list_cards(params)
    now = DateTime.utc_now()
    file_name = "Everlearn_cards_export#{now.year}-#{now.month}-#{now.day}-#{now.hour}#{now.minute}#{now.second}.xlsx"
    conn
      |> put_resp_content_type("text/xlsx")
      |> put_resp_header("content-disposition", "attachment; filename=#{file_name}")
      |> render(EverlearnWeb.Reports.CardView, "report.xlsx", %{cards: cards})
  end

end

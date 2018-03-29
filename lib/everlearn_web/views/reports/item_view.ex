defmodule EverlearnWeb.Reports.ItemView do
  use EverlearnWeb, :view
  alias Elixlsx.{Workbook, Sheet}

  @header ["ID", "Classroom", "Topic", "Kind", "Level", "Title", "Description"]

  def render("report.xlsx", %{items: items}) do
    report_generator(items)
      |> Elixlsx.write_to_memory("export_item.xlsx")
      |> elem(1)
      |> elem(1)
  end

  def report_generator(items) do
    rows = items |> Enum.map(&(row(&1)))
    %Workbook{sheets: [%Sheet{name: "Items", rows: [@header] ++ rows}]}
  end

  def row(item) do
    [item.id, item.classroom.title, item.topic.title, item.kind.title, item.level, item.title, item.description]
  end
end

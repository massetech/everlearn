defmodule EverlearnWeb.Reports.ItemView do
  use EverlearnWeb, :view
  alias Elixlsx.{Workbook, Sheet}

  @header ["Topic_id", "Topic", "Kind_id", "Kind", "Item_id", "Title", "Level", "Description", "Picture_link",
    "Question", "Answer", "Sound", "Phonetic"]

  def render("report.xlsx", %{items: items}) do
    report_generator(items)
      |> Elixlsx.write_to_memory("export_item.xlsx")
      |> elem(1)
      |> elem(1)
  end

  def report_generator(items) do
    rows = items |> Enum.map(&(row(&1)))
    classroom = List.first(items).classroom.title
    %Workbook{sheets: [%Sheet{name: "#{classroom} items", rows: [@header] ++ rows}]}
  end

  def row(item) do
    [item.topic.id, item.topic.title, item.kind.id, item.kind.title, item.id, item.title, item.level, item.description, item.picture]
  end
end

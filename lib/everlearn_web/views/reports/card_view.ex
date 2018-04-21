defmodule EverlearnWeb.Reports.CardView do
  use EverlearnWeb, :view
  alias Elixlsx.{Workbook, Sheet}

  @header ["Language", "Kind", "Item_id", "Item", "Topic", "Description", "Level",
    "Card_id", "Question", "Answer", "Sound", "Phonetic"]

  def render("report.xlsx", %{cards: cards}) do
    report_generator(cards)
      |> Elixlsx.write_to_memory("export_cards.xlsx")
      |> elem(1)
      |> elem(1)
  end

  def report_generator(cards) do
    rows = cards |> Enum.map(&(row(&1)))
    %Workbook{sheets: [%Sheet{name: "Cards", rows: [@header] ++ rows}]}
  end

  def row(card) do
    [card.language.title, card.item.kind.title, card.item.id, card.item.title,
    card.item.topic.title, card.item.description, card.item.level,
    card.id, card.question, card.answer, card.sound, card.phonetic]
  end
end

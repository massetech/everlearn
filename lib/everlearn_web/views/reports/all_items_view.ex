defmodule EverlearnWeb.Reports.AllItemsView do
  use EverlearnWeb, :view
  alias Elixlsx.{Workbook, Sheet}

  @header1 ["Topic_id", "Topic", "Kind_id", "Kind", "Item_id", "Title", "Level", "Description", "Picture_link", "Active"]

  @header2 ["Kind", "Item_id", "Title", "Question", "Answer", "Sound", "Phonetic", "Active"]

  def render("report.xlsx", %{items: items}) do
    report_generator(items)
      |> Elixlsx.write_to_memory("export_item.xlsx")
      |> elem(1)
      |> elem(1)
  end

  def report_generator(items) do
    rows_item = items |> Enum.map(&(row_item(&1)))
    rows_cards_fr = load_card_datas_for_language(items, "fr")
    rows_cards_en = load_card_datas_for_language(items, "en")
    rows_cards_bi = load_card_datas_for_language(items, "bi")
    rows_cards_cn = load_card_datas_for_language(items, "cn")
    %Workbook{
      sheets: [
        %Sheet{name: "All items", rows: [@header1] ++ rows_item},
        %Sheet{name: "Cards FR", rows: [@header2] ++ rows_cards_fr},
        %Sheet{name: "Cards EN", rows: [@header2] ++ rows_cards_en},
        %Sheet{name: "Cards BI", rows: [@header2] ++ rows_cards_bi},
        %Sheet{name: "Cards CN", rows: [@header2] ++ rows_cards_cn}
      ]
    }
  end

  def load_card_datas_for_language(items, language) do
    items
      |> Enum.map(fn item -> load_item_cards_rows(item, language) end)
      |> Enum.filter(fn array -> array != [] end)
  end

  def load_item_cards_rows(item, language) do
    row_list = item.cards
      |> Enum.filter(fn card -> card.language.iso2code == language end)
      |> Enum.map(fn card -> row_card(item, card) end)
      |> List.flatten()
  end

  def row_item(item) do
    [item.topic.id, item.topic.title, item.kind.id, item.kind.title, item.id, item.title, item.level, item.description, item.picture, to_string(item.active)]
  end

  def row_card(item, card) do
    [item.kind.title, item.id, item.title, card.question, card.answer, card.sound, card.phonetic, to_string(card.active)]
  end

end

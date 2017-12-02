defmodule Everlearn.CustomSelects do

  def kind_menu do
    # {vocabulary: "vocabulary", culture: "culture"}
    [vocabulary: "vocabulary", culture: "culture"]
  end

  def status_select_btn do
    [active: true, inactive: false]
  end

  def level_menu do
    [beginner: 1, intermediate: 2, expert: 3]
  end

end

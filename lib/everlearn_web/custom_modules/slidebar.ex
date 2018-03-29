defmodule Everlearn.Slidebars do

  def navbar_player(data) do
    menu = data.classrooms
      |> Enum.map(fn(classroom) -> %{title: classroom.title, id: classroom.id, memberships: get_memberships_slidebar_data(classroom)} end)
  %{slidebar: menu}
    |> IO.inspect()
  end

  defp get_memberships_slidebar_data(classroom) do
    classroom.memberships
      |> Enum.map(fn(membership) -> get_membership_slidebar_data(membership) end)
  end

  defp get_membership_slidebar_data(membership) do
    nb_cards_in_membership = membership.cards
      |> length()
      # |> Enum.reduce(0, fn(item, acc) -> acc + count_cards_in_item(item) end)
    %{id: membership.id, title: membership.title, languages: membership.languages, nb_cards: nb_cards_in_membership}
  end

  def count_cards_in_item(item) do
    item.cards
      |> Enum.count()
  end

end

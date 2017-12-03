defmodule Everlearn.QueryFilter do
  alias Everlearn.Contents.{Item}

  def filter(params, model) do
    case Map.has_key?(params, "search") do
      true -> Map.put(%{}, "search", map_filters(params, model))
      false -> %{}
    end
  end

  defp map_filters(params, model) do
    IO.inspect(params)
    model.filters
    |> Enum.reduce(%{}, fn({k, v}, acc) -> Map.put(acc, Atom.to_string(k), query_map(params, k, v)) end)
  end

  defp query_map(params, k, v) do
    %{"assoc" => [], "search_type" => v, "search_term" => params["search"][Atom.to_string(k)]}
  end

  # Rummage needs this kind of map : Item.rummage(...)
  # %{
  #  "search" => %{
  #    "title" => %{"assoc" => [], "search_type" => "ilike", "search_term" => params["search"]["title"]},
  #    "level" => %{"assoc" => [], "search_type" => "eq", "search_term" => params["search"]["level"]},
  #    "active" => %{"assoc" => [], "search_type" => "eq", "search_term" => params["search"]["active"]},
  #    "kind_id" => %{"assoc" => [], "search_type" => "eq", "search_term" => params["search"]["kind"]},
  #    "topic_id" => %{"assoc" => [], "search_type" => "eq", "search_term" => params["search"]["topic"]}
  #  }

end

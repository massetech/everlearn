defmodule Everlearn.QueryFilter do

  # Add search keys according to rummage to fill the search bar
  def add_rummage_search(rummage) do
    case Map.has_key?(rummage, "search") do
      true -> map_rummage_search(rummage)
      false -> %{}
    end
  end

  defp map_rummage_search(rummage) do
    rummage["search"]
    |> Enum.reduce(%{}, fn({k, v}, acc) -> Map.put(acc, k, v["search_term"]) end)
  end

  # Build Rummage query
  def build_rummage_query(params, model) do
    # Returns {rummage_query, rummage} for this model
    filtered_params = filter_rummage_params(params, model)
    model
      |> Rummage.Ecto.rummage(filtered_params)
  end

  defp filter_rummage_params(params, model) do
    params
      |> check_rummage_key()
      |> add_filters_to_rummage(model)
  end

  defp check_rummage_key(params) do
    case Map.has_key?(params, "rummage") do
      true -> params
      false -> Map.put(params, "rummage", %{})
    end
  end

  defp add_filters_to_rummage(params, model) do
    case Map.has_key?(params, "search") do
      true -> Map.put(params["rummage"], "search", map_filters(params, model))
      false -> params["rummage"]
    end
  end

  defp map_filters(params, model) do
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

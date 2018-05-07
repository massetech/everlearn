defmodule Everlearn.QueryFilter do
  def build_rummage_query(params, model) do
    # Returns {rummage_query, rummage} for the model
    filtered_params = params
      |> IO.inspect()
      |> check_rummage_key(model) # Check that rummage key exists or create it with default params
      |> add_filters_to_rummage(model) # Add filters to rummage if search key found in params
      # |> IO.inspect()
    model
      |> Rummage.Ecto.rummage(filtered_params)
      |> IO.inspect()
  end
  #
  # def add_default_search_params(params, model) do
  #   rummage = params["rummage"]
  #     |> IO.inspect()
  #     |> Enum.map(fn {k, v} -> add_default_search({k, v}, model) end)
  # end
  #
  # defp add_default_search({k, v}, model) do
  #   case Map.has_key?(model.filters, k) do
  #     true -> if v == "", do: {k, model.filters.v}, else: {k, v}
  #     false -> {k, v}
  #   end
  # end

  # defp filter_rummage_params(params, model) do
  #   params
  #     |> check_rummage_key()
  #     |> add_filters_to_rummage(model)
  # end

  defp check_rummage_key(params, model) do
    case Map.has_key?(params, "rummage") do
      true -> params
      false -> Map.put(params, "rummage", model.default_filters) # Page initialization
    end
  end

  defp add_filters_to_rummage(params, model) do
    case Map.has_key?(params, "search") do
      true -> Map.put(params["rummage"], "search", map_filters(params, model)) # Add search fields to rummage
      false -> params["rummage"] # No search : use rummage
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

  # # Add search keys according to rummage to fill the search bar
  # def add_rummage_search(rummage) do
  #   case Map.has_key?(rummage, "search") do
  #     true ->
  #       IO.puts("no rummage params : initialized")
  #       map_rummage_search(rummage)
  #     false ->
  #       IO.puts("no rummage params : initialized")
  #       %{}
  #   end
  # end

  # defp map_rummage_search(rummage) do
  #   rummage["search"]
  #   |> Enum.reduce(%{}, fn({k, v}, acc) -> Map.put(acc, k, v["search_term"]) end)
  # end

  # def map_rummage_search_params (params, model) do
  #   params
  #     |> check_rummage_key()
  #     |> add_filters_to_rummage(model)
  # end

end

defmodule EverlearnWeb.PackView do
  use EverlearnWeb, :view

  def list_item_ids(items_map) do
    items_map
    # Destruct the maps
    |> Enum.map(fn (struct) -> Map.from_struct(struct) end)
    # Filter maps to keep only IDs
    |> Enum.map(& &1[:id])
  end

end

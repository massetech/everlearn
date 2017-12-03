defmodule Everlearn.Imports do

  alias Everlearn.Contents.{Item}
  alias Everlearn.Contents

  def flash_answers({nb_line, _, model, %{ok: success}}) do
    case count_success(success) do
      0 -> {:error, "No #{model} was imported"}
      nb_line -> {:success, "All #{model}s were imported"}
      _ -> {:info, "#{model}s were imported with errors"}
    end
  end

  defp count_success(success) do
    success
      |> Enum.count()
      |> IO.inspect()
  end

  def import(file, module, model, headers, nested_tuple \\ nil) do
    case nested_tuple do
      nil ->
        file
          |> File.stream!()
          |> CSV.decode(separator: ?;, headers: headers)
          |> Enum.drop(1) # Remove the first line with headers
          |> Enum.reduce({1, module, model, %{ok: [], errors: []}}, &insert_line/2)
      {nested_atom, nested_id} -> # There is a nested map ie topic_id
        file
          |> File.stream!()
          |> CSV.decode(separator: ?;, headers: headers)
          |> Enum.drop(1) # Remove the first line with headers
          |> Enum.map(fn {k, v} -> {k, Map.put(v, nested_atom, nested_id)} end)
          |> Enum.reduce({1, module, model, %{ok: [], errors: []}}, &insert_line/2)
    end
  end

  defp insert_line({status, fields} = line, {x, module, model, results}) do
    case status do
      :ok -> # This line is ok for inserting
        case apply(Module.concat(Everlearn, module), String.to_atom("save_#{model}_line"), [fields]) do
          {:ok, msg} -> {x + 1, module, model, %{ok: results.ok ++ ["line_#{x}"], errors: results.errors}}
          {:error, msg} -> {x + 1, module, model, %{ok: results.ok, errors: results[:errors] ++ [{"line_#{x}", msg}]}}
        end
      _ -> # This line has a problem in the file
        {x + 1, module, model, %{ok: results.ok, errors: results[:errors] ++ ["line_#{x}"]}}
    end
  end

end

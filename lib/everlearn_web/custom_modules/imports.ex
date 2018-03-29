defmodule Everlearn.Imports do
  use EverlearnWeb, :controller
  alias Everlearn.Contents
  alias Everlearn.Contents.Item

  def add_flash_answers(conn, %{success_lines: success_lines, error_lines: error_lines, nb_line: nb_line} = results) do
    cond do
      length(success_lines) == nb_line ->
        conn
          |> put_flash(:success, "All #{nb_line} lines were imported")
      length(success_lines) == 0 ->
        IO.inspect(results)
        conn
          |> put_flash(:error, "No line were imported (#{nb_line} lines)")
      true ->
        IO.inspect(results)
        conn
          |> put_flash(:info, "#{length(success_lines)} lines were imported")
          |> put_flash(:error, "#{length(error_lines)} lines were not imported")
    end
  end

  def import(file, module, model, params, excluded_atoms \\ []) do
    tid = Xlsxir.multi_extract(file, 0, true) # Returns {:ok, table_id, time_array}
    case tid do
      {:ok, table_id, time_array} ->
        IO.puts("Imported in #{convert_xls_time(time_array)}")
        # To get from the 1st row
        headers = table_id
          # Convert first row into list of header atoms
          |> Xlsxir.get_row(1)
          |> Enum.map(fn(header) -> String.to_atom(header) end)
          # |> Enum.filter(fn(atom) -> atom not in excluded_atoms end)
          # |> IO.inspect()
        import_result = table_id
          |> Xlsxir.get_list()
          # Remove the first line with headers
          |> Enum.drop(1)
          # |> IO.inspect()
          # Try to save each line
          |> Enum.map(fn(line_array) -> insert_imported_line(module, model, line_array, headers, params, excluded_atoms) end)
          # Filter the report from saving to debug
          |> Enum.reduce(%{success_lines: [], error_lines: [], nb_line: 1}, &report_import/2)
        Xlsxir.close(table_id)
        {:ok, import_result}
      {:error, msg} ->
        {:error, msg}
    end
  end

  defp insert_imported_line(module, model, line_array, headers, params, excluded_atoms) do
    params = headers
      |> Enum.zip(line_array)
      |> Enum.into(params)
      |> Map.drop(excluded_atoms)
      # |> IO.inspect()
      # |> Enum.map(fn(k, v) -> x * 2 end)
      # |> IO.inspect()
    # Call the create function of the model iex Contents.create_item(params)
    apply(Module.concat(Everlearn, module), String.to_atom("create_#{model}"), [params])
  end

  defp report_import(report_line, %{success_lines: success_list, error_lines: error_list, nb_line: line_nb}) do
    case report_line do
      {:ok, _model} ->
        %{success_lines: success_list ++ [line_nb], error_lines: error_list, nb_line: line_nb + 1}
      {:error, changeset} ->
        %{success_lines: success_list, error_lines: error_list ++ [%{line: line_nb, errors: changeset.errors}], nb_line: line_nb + 1}
    end
  end

  defp convert_xls_time(time_array) do
    "#{Enum.at(time_array, 0)}h #{Enum.at(time_array, 1)}min #{Enum.at(time_array, 2)}seconds}"
  end

  # def import(file, module, model, headers, nested_tuple \\ nil) do
  #   case nested_tuple do
  #     nil ->
  #       file
  #         |> File.stream!()
  #         |> CSV.decode(separator: ?;, headers: headers)
  #         |> Enum.drop(1) # Remove the first line with headers
  #         |> Enum.reduce({1, module, model, %{ok: [], errors: []}}, &insert_line/2)
  #     {nested_key, nested_id} -> # There is a nested map ie topic_id
  #       file
  #         |> File.stream!()
  #         |> CSV.decode(separator: ?;, headers: headers)
  #         |> Enum.drop(1) # Remove the first line with headers
  #         |> Enum.map(fn {k, v} -> {k, Map.put(v, nested_key, nested_id)} end)
  #         |> Enum.reduce({1, module, model, %{ok: [], errors: []}}, &insert_line/2)
  #   end
  # end

  # defp insert_line({status, fields}, {x, module, model, results}) do
  #   case status do
  #     :ok -> # This line is ok for inserting
  #       case apply(Module.concat(Everlearn, module), String.to_atom("save_#{model}_line"), [fields]) do
  #         {:ok, _msg} -> {x + 1, module, model, %{ok: results.ok ++ ["line_#{x}"], errors: results.errors}}
  #         {:error, msg} -> {x + 1, module, model, %{ok: results.ok, errors: results[:errors] ++ [{"line_#{x}", msg}]}}
  #       end
  #     _ -> # This line has a problem in the file
  #       {x + 1, module, model, %{ok: results.ok, errors: results[:errors] ++ ["line_#{x}"]}}
  #   end
  # end

end

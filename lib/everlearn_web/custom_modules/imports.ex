defmodule Everlearn.Imports do
  use EverlearnWeb, :controller
  alias Everlearn.Contents
  alias Everlearn.Contents.Item

  def add_flash_answers(conn, %{success_lines: success_lines, error_lines: error_lines, nb_line: nb_line} = results) do
    cond do
      length(error_lines) == 0 ->
        conn
          |> put_flash(:success, "All #{nb_line} lines were imported")
      length(success_lines) == 0 ->
        conn
          |> put_flash(:error, "No line were imported (#{nb_line} lines)")
      true ->
        conn
          |> put_flash(:info, "#{length(success_lines)} lines were imported")
          |> put_flash(:error, "#{length(error_lines)} lines were not imported")
    end
  end

  defp insert_line(line_array, headers, params) do
    params = headers
      |> Enum.zip(line_array)
      |> Enum.into(params)
      |> IO.inspect()
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
          |> Enum.map(fn(header_atom) -> String.downcase(header_atom) end)
          |> Enum.map(fn(header_atom) -> String.to_atom(header_atom) end)
        import_result = table_id
          |> Xlsxir.get_list()
          # Remove the first line with headers
          |> Enum.drop(1)
          # Try to save each line
          |> Enum.map(fn(line_array) -> insert_or_update_imported_line(module, model, line_array, headers, params, excluded_atoms) end)
          # Filter the report from saving to debug
          |> Enum.reduce(%{success_lines: [], error_lines: [], nb_line: 1}, &report_import/2)
        Xlsxir.close(table_id)
        {:ok, import_result}
      {:error, msg} ->
        {:error, msg}
    end
  end

  defp insert_or_update_imported_line(module, model, line_array, headers, params, excluded_atoms) do
    params = headers
      |> Enum.zip(line_array)
      |> Enum.into(params)
      |> Map.drop(excluded_atoms)
      |> IO.inspect()
    # If Id field is empty, it is a new record if not it is an update
    model_id_atom = String.to_atom("#{model}_id")
    case Map.get(params, model_id_atom) do
      nil ->
        # Call the create function of the model iex Contents.create_item(params)
        IO.puts("creating")
        apply(Module.concat(Everlearn, module), String.to_atom("create_#{model}"), [params])
      id ->
        # Call the update function of the model iex Contents.update_item(params)
        IO.puts("updating")
        element = apply(Module.concat(Everlearn, module), String.to_atom("get_#{model}"), [id])
        case element do
          nil ->
            {:unfound, "record not found #{id}"}
          element ->
            apply(Module.concat(Everlearn, module), String.to_atom("update_#{model}"), [element, params])
        end
    end
  end

  defp report_import(report_line, %{success_lines: success_list, error_lines: error_list, nb_line: line_nb}) do
    case report_line do
      {:ok, _model} ->
        %{success_lines: success_list ++ [line_nb], error_lines: error_list, nb_line: line_nb + 1}
      {:error, changeset} ->
        %{success_lines: success_list, error_lines: error_list ++ [%{line: line_nb, errors: changeset.errors}], nb_line: line_nb + 1}
      {:unfound, msg} ->
        %{success_lines: success_list, error_lines: error_list ++ [%{line: line_nb, errors: msg}], nb_line: line_nb + 1}
    end
  end

  defp convert_xls_time(time_array) do
    "#{Enum.at(time_array, 0)}h #{Enum.at(time_array, 1)}min #{Enum.at(time_array, 2)}seconds}"
  end
end

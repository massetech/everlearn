defmodule Everlearn.Imports do
  use EverlearnWeb, :controller
  alias Everlearn.Contents
  alias Everlearn.Contents.Item

  def import_items(file, params) do
    module = Everlearn.Contents
    model = "item"
    import_fields = Everlearn.Contents.Item.import_fields()
    tid_array = Xlsxir.multi_extract(file, nil, true) # Returns [{:ok, table_1_id}, ...]
      |> Enum.map(fn(tid) -> import_worksheet(tid, params, import_fields, module, model) end) # Returns [ok: %{results}, errors: %{results}]
  end

  def import_cards(file, params) do
    module = Everlearn.Contents
    model = "card"
    import_fields = Everlearn.Contents.Card.import_fields()
    tid_array = Xlsxir.multi_extract(file, nil, true) # Returns [{:ok, table_1_id}, ...]
      |> Enum.map(fn(tid) -> import_worksheet(tid, params, import_fields, module, model) end) # Returns [ok: %{results}, errors: %{results}]
  end

  def import_packitems(file, params) do
    module = Everlearn.Contents
    model = "packitem"
    import_fields = Everlearn.Contents.PackItem.import_fields()
    tid_array = Xlsxir.multi_extract(file, nil, true) # Returns {:ok, table_1_id}
      |> Enum.map(fn(tid) -> import_worksheet(tid, params, import_fields, module, model) end) # Returns [ok: %{results}, errors: %{results}]
  end

  defp convert_xls_time(time_array) do
    "#{Enum.at(time_array, 0)}h #{Enum.at(time_array, 1)}min #{Enum.at(time_array, 2)}seconds}"
  end

  defp import_worksheet(tid, params, import_fields, module, model) do
    case tid do
      {:ok, table_id, time_array} -> # This worksheet was parsed : treat it
        time_spent = convert_xls_time(time_array)
        headers = table_id
          # Convert the first row into a list of header atoms
          |> Xlsxir.get_row(1)
          |> Enum.filter(fn(k) -> k != nil end) # Filter the headers = nil (modified cell)
          |> Enum.map(fn(header_atom) -> String.downcase(header_atom) end)
          |> Enum.map(fn(header_atom) -> String.to_atom(header_atom) end)
        import_result = table_id
          # Import the lines
          |> Xlsxir.get_list()
          |> Enum.drop(1)
          |> Enum.map(fn(line_array) -> import_line(line_array, headers, params, import_fields, module, model) end)
          |> Enum.reduce(%{success_lines: [], error_lines: [], nb_line: 1}, &report_import/2)
        Xlsxir.close(table_id)
        {:ok, import_result, time_spent}
      {:error, msg} -> # This worksheet was not parsed : report an error
        {:error, msg}
    end
  end

  defp import_line(line_array, headers, params, import_fields, module, model) do
    model_id = String.to_atom("#{model}_id")
    action = String.to_atom("import_#{model}")
    given_params = headers
      |> Enum.zip(line_array)
      |> Enum.filter(fn({k, v}) -> Enum.member?(import_fields, k) end) # Filter the import fields
      |> Enum.into(params) # Params is a map
      |> IO.inspect()
    id = Map.get(given_params, model_id)
    sorted_params = given_params
      |> Map.drop([model_id])
      |> Map.put(:id, id)
    case apply(module, action, [sorted_params]) do
      {:ok, element} -> {:ok, "#{model} with id = #{element.id} was treated"}
      {:error, changeset} -> {:error, changeset}
    end
  end

  def analyse_and_log_results(result_array) do
    result_array
      |> Enum.map(fn(ws_result) -> analyse_ws_result(ws_result) end)
  end

  defp analyse_ws_result(ws_result) do
    case ws_result do
      {:ok, result_map, duration} ->
        nb_errors = Enum.count(result_map.error_lines)
        nb_success = Enum.count(result_map.success_lines)
        IO.puts("Worksheet imported in #{duration} for #{result_map.nb_line} lines.")
        IO.puts("Nb success : #{nb_success}, nb errors : #{nb_errors}.")
        IO.inspect(result_map)
      {:error, msg} -> IO.puts(msg)
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

  # defp insert_line(line_array, headers, params) do
  #   params = headers
  #     |> Enum.zip(line_array)
  #     |> Enum.into(params)
  #     # |> IO.inspect()
  # end
  #
  # def import(file, module, model, params, excluded_atoms \\ []) do
  #   tid_array = Xlsxir.multi_extract(file, nil, true) # Returns [{:ok, table_1_id}, ...]
  #     |> Enum.map(fn(tid) -> import_worksheet(tid, module, model, params, excluded_atoms) end) # Returns [ok: %{results}, errors: %{results}]
  #     # |> IO.inspect()
  # end

  #
  # def add_flash_answers(conn, results_array) do
  #   # status = results_array
  #   #   |> IO.inspect()
  #   #   |> Enum.flat_map_reduce(0, fn(result, acc) -> control_ws_result(result, acc) end)
  #   #   # {info: "Worksheet 1  was imported with n success and n problems",
  #   #   #   success: "Worksheet 2  was imported with n success",
  #   #   #   alert: "Worksheet 3 was imported with 0 success"
  #   #   #   }
  #   # conn
  #     # |> Enum.flat_map_reduce(0, fn(result, acc) -> control_result(result.ok, acc) end)
  #   # %{success_lines: success_lines, error_lines: error_lines, nb_line: nb_line} =
  #   # conn = results_arrays
  #   #   |> Enum.map(fn(result) -> add_flash_answer(result) end)
  #   # cond do
  #   #   length(error_lines) == 0 ->
  #   #     conn
  #   #       |> put_flash(:success, "All #{nb_line} lines were imported")
  #   #   length(success_lines) == 0 ->
  #   #     conn
  #   #       |> put_flash(:error, "No line were imported (#{nb_line} lines)")
  #   #   true ->
  #   #     conn
  #   #       |> put_flash(:info, "#{length(success_lines)} lines were imported")
  #   #       |> put_flash(:error, "#{length(error_lines)} lines were not imported")
  #   # end
  # end

end

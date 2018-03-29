defmodule Everlearn.CustomMethods do

  def get_first_error(errors_array) do
    [{title, {msg, _}} | _tail] = errors_array
    "Check first error : #{title} : #{msg}"
  end

  def get_from_array(array) do
    Enum.fetch!(array, 0)
  end

  @moduledoc """
  Convert strings into booleans
  """
  def convert_boolean(string) do
    case string do
      "Y" -> true
      "y" -> true
      "yes" -> true
      "X" -> true
      "1" -> true
      _ -> false
    end
  end

  def convert_integer(string) do
    case Integer.parse(string) do
      {value, _} ->
        {:ok, value}
      _ ->
        {:error, string}
    end
  end

end

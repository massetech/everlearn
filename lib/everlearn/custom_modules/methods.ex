defmodule Everlearn.CustomMethods do

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
        value
      _ ->
        string
    end
  end

end

defmodule EverlearnWeb.DataView do
  use EverlearnWeb, :view
  alias EverlearnWeb.DataView

  def render("index.json", %{api_data: content}) do
    %{api_data: content}
  end

end

defmodule EverlearnWeb.DataView do
  use EverlearnWeb, :view
  alias EverlearnWeb.DataView

  def render("index.json", %{api_answer_data: content}) do
    %{api_answer_data: content}
  end

end

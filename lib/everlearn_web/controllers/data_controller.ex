defmodule EverlearnWeb.DataController do
  use EverlearnWeb, :controller
  alias Everlearn.Members
  alias Everlearn.Members.Data

  # plug Everlearn.Plug.DisplayFlashes
  action_fallback EverlearnWeb.FallbackController

  def update_user_data(conn, %{"classrooms" => classrooms, "options" => options}) do
    classrooms
      |> Members.update_user_data()
    content = Members.get_user_learning_data(conn.assigns.current_user.id)
    conn
      |> render("index.json", api_answer_data: content)
  end

end

defmodule EverlearnWeb.TopicController do
  use EverlearnWeb, :controller
  alias Everlearn.Contents
  alias Everlearn.Contents.Topic

  plug Everlearn.Plug.DisplayFlashes
  plug :load_select when action in [:new, :edit]
  plug :fetch_navtitle_index when action in [:index]
  plug :fetch_navtitle_other when action in [:new, :show, :edit, :create, :update]

  defp fetch_navtitle_index(conn, _params) do
    conn
    |> assign(:nav_title, "Topics")
    |> assign(:nav_new_path, topic_path(conn, :new))
  end

  defp fetch_navtitle_other(conn, _params) do
    conn
    |> assign(:nav_title, "Topic")
    |> assign(:nav_index_path, topic_path(conn, :index))
  end

  defp load_select(conn, _params) do
    conn
    |> assign(:classrooms, Contents.classroom_select_btn())
  end

  def index(conn, _params) do
    topics = Contents.list_topics()
    render(conn, "index.html", topics: topics)
  end

  def new(conn, _params) do
    changeset = Contents.change_topic(%Topic{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"topic" => topic_params}) do
    case Contents.create_topic(topic_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: topic_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  # def show(conn, %{"id" => id}) do
  #   topic = Contents.get_topic!(id)
  #   render(conn, "show.html", topic: topic)
  # end

  def edit(conn, %{"id" => id}) do
    topic = Contents.get_topic!(id)
    changeset = Contents.change_topic(topic)
    render(conn, "edit.html", topic: topic, changeset: changeset)
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Contents.get_topic!(id)

    case Contents.update_topic(topic, topic_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: topic_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", topic: topic, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Contents.get_topic!(id)
    {:ok, _topic} = Contents.delete_topic(topic)

    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: topic_path(conn, :index))
  end
end

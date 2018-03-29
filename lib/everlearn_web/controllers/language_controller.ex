defmodule EverlearnWeb.LanguageController do
  use EverlearnWeb, :controller
  alias Everlearn.Members
  alias Everlearn.Members.Language

  plug Everlearn.Plug.DisplayFlashes
  plug :fetch_navtitle_index when action in [:index]
  plug :fetch_navtitle_other when action in [:new, :show, :edit, :create, :update]
  plug :load_select when action in [:new, :edit, :create, :update]

  defp fetch_navtitle_index(conn, _params) do
    conn
    |> assign(:nav_title, "Languages")
    |> assign(:nav_new_path, language_path(conn, :new))
  end

  defp fetch_navtitle_other(conn, _params) do
    conn
    |> assign(:nav_title, "Language")
    |> assign(:nav_index_path, language_path(conn, :index))
  end

  defp load_select(conn, _params) do
    conn
    |> assign(:iso2codes, Language.iso2code_select_btn())
  end

  def index(conn, _params) do
    languages = Members.list_languages()
    render(conn, "index.html", languages: languages)
  end

  def new(conn, _params) do
    changeset = Members.change_language(%Language{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"language" => language_params}) do
    case Members.create_language(language_params) do
      {:ok, _language} ->
        conn
        |> put_flash(:info, "Language created successfully.")
        |> redirect(to: language_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    language = Members.get_language!(id)
    render(conn, "show.html", language: language)
  end

  def edit(conn, %{"id" => id}) do
    language = Members.get_language!(id)
    changeset = Members.change_language(language)
    render(conn, "edit.html", language: language, changeset: changeset)
  end

  def update(conn, %{"id" => id, "language" => language_params}) do
    language = Members.get_language!(id)

    case Members.update_language(language, language_params) do
      {:ok, _language} ->
        conn
        |> put_flash(:info, "Language updated successfully.")
        |> redirect(to: language_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", language: language, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    language = Members.get_language!(id)
    {:ok, _language} = Members.delete_language(language)

    conn
    |> put_flash(:info, "Language deleted successfully.")
    |> redirect(to: language_path(conn, :index))
  end
end

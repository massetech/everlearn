defmodule EverlearnWeb.CardController do
  use EverlearnWeb, :controller
  use Rummage.Phoenix.Controller

  alias Everlearn.Contents
  alias Everlearn.Contents.Card
  plug :load_select when action in [:new, :create, :edit, :update]

  defp load_select(conn, _params) do
    assign(conn, :languages, Everlearn.Members.language_select_btn())
  end

  def index(conn, params) do
    {query, rummage} = Card
    |> Card.rummage(params["rummage"])
    cards = Contents.list_cards()
    changeset = Contents.change_card(%Card{})
    render(conn, "index.html", cards: cards, changeset: changeset, rummage: rummage)
  end

  # Module to import Cards and items from CSV
  def import(conn, %{"card" => card_params}) do
    topic_id = card_params["topic_id"]
    file = card_params["file"].path
    Contents.import_cards(topic_id, file)
    conn
    |> put_flash(:info, "Imported but might be some errors")
    |> redirect(to: item_path(conn, :index))
  end

  def new(conn, %{"item_id" => item_id}) do
    changeset = Contents.change_card(%Card{item_id: item_id})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"card" => card_params}) do
    case Contents.create_card(card_params) do
      {:ok, card} ->
        conn
        |> put_flash(:info, "Card created successfully.")
        |> redirect(to: card_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    card = Contents.get_card!(id)
    render(conn, "show.html", card: card)
  end

  def edit(conn, %{"id" => id}) do
    card = Contents.get_card!(id)
    changeset = Contents.change_card(card)
    render(conn, "edit.html", card: card, changeset: changeset)
  end

  def update(conn, %{"id" => id, "card" => card_params}) do
    card = Contents.get_card!(id)

    case Contents.update_card(card, card_params) do
      {:ok, card} ->
        conn
        |> put_flash(:info, "Card updated successfully.")
        |> redirect(to: card_path(conn, :index))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", card: card, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    card = Contents.get_card!(id)
    {:ok, _card} = Contents.delete_card(card)

    conn
    |> put_flash(:info, "Card deleted successfully.")
    |> redirect(to: card_path(conn, :index))
  end
end

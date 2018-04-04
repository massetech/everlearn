defmodule EverlearnWeb.CardController do
  use EverlearnWeb, :controller
  use Rummage.Phoenix.Controller
  alias Everlearn.{Contents, CustomSelects, Imports}
  alias Everlearn.Contents.Card

  plug Everlearn.Plug.DisplayFlashes
  plug :load_select when action in [:index, :new, :create, :edit, :update]
  plug :fetch_navtitle_index when action in [:index]
  plug :fetch_navtitle_other when action in [:new, :show, :edit, :create, :update]

  defp fetch_navtitle_index(conn, _params) do
    conn
    |> assign(:nav_title, "Cards")
  end

  defp fetch_navtitle_other(conn, _params) do
    conn
    |> assign(:nav_title, "Card")
    |> assign(:nav_index_path, card_path(conn, :index))
  end

  defp load_select(conn, _params) do
    conn
    |> assign(:languages, Everlearn.Members.language_select_btn())
    |> assign(:active, CustomSelects.status_select_btn())
    |> assign(:languages, Everlearn.Members.language_select_btn())
  end

  def index(conn, params) do
    {cards, rummage} = Contents.list_cards(params)
    changeset = Contents.change_card(%Card{})
    conn
      |> assign(:import_action, import_cards_path(conn, :card))
      |> render("index.html", cards: cards, changeset: changeset, rummage: rummage)
  end

  # # Module to import Cards and items from CSV
  # def import(conn, %{"card" => card_params}) do
  #   msg = card_params["file"].path
  #     |> Imports.import("Contents", "card", Card.import_fields, nil)
  #     |> Imports.flash_answers()
  #   conn
  #     |> put_flash(elem(msg, 0), elem(msg, 1))
  #     |> redirect(to: card_path(conn, :index))
  # end

  def new(conn, %{"item_id" => item_id}) do
    changeset = Contents.change_card(%Card{item_id: item_id})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"card" => card_params}) do
    case Contents.create_card(card_params) do
      {:ok, card} ->
        conn
        |> put_flash(:info, "Card created successfully.")
        |> redirect(to: item_path(conn, :show, card.item_id))
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
      {:ok, _card} ->
        conn
        # |> put_flash(:info, "Card updated successfully.")
        |> redirect(to: item_path(conn, :show, card.item_id))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", card: card, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    card = Contents.get_card!(id)
    {:ok, _card} = Contents.delete_card(card)

    conn
    # |> put_flash(:info, "Card deleted successfully.")
    |> redirect(to: item_path(conn, :show, card.item_id))
  end
end

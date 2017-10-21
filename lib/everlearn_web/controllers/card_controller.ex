defmodule EverlearnWeb.CardController do
  use EverlearnWeb, :controller

  alias Everlearn.Contents
  alias Everlearn.Contents.Card
  plug :load_select when action in [:new, :edit]

  defp load_select(conn, _params) do
    assign(conn, :topics, Everlearn.Contents.topic_select_btn())
  end

  def index(conn, _params) do
    cards = Contents.list_cards()
    render(conn, "index.html", cards: cards)
  end

  # Module to import Cards and items from CSV
  def import(conn, %{"card" => card_params}) do
    topic_id = card_params["topic_id"]
    callback = card_params["file"].path
    |> File.stream!()
    |> CSV.decode(separator: ?;, headers: [
      :item_id, :item_group, :item_title, :item_level, :item_description, :item_active,
      :card_language, :card_title, :card_active
    ])
    |> Enum.map(fn (line) ->
      Everlearn.Contents.insert_card(line, topic_id)
      |> IO.inspect()
    end)
    conn
    |> redirect(to: item_path(conn, :index))
    # |> Enum.filter(fn
    #   {:error, _} -> true
    #   _ -> false
    # end)
    # |> case do
    #   [] ->
    #     conn
    #     |> put_flash(:info, "Imported without error")
    #     |> redirect(to: item_path(conn, :index))
    #   errors ->
    #     conn
    #     |> put_flash(:error, errors)
    #     |> render("import.html")
    # end
  end

  def new(conn, _params) do
    changeset = Contents.change_card(%Card{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"card" => card_params}) do
    case Contents.create_card(card_params) do
      {:ok, card} ->
        conn
        |> put_flash(:info, "Card created successfully.")
        |> redirect(to: card_path(conn, :show, card))
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
        |> redirect(to: card_path(conn, :show, card))
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

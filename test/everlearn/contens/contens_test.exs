defmodule Everlearn.ContensTest do
  use Everlearn.DataCase

  alias Everlearn.Contens

  describe "topics" do
    alias Everlearn.Contens.Topic

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def topic_fixture(attrs \\ %{}) do
      {:ok, topic} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contens.create_topic()

      topic
    end

    test "list_topics/0 returns all topics" do
      topic = topic_fixture()
      assert Contens.list_topics() == [topic]
    end

    test "get_topic!/1 returns the topic with given id" do
      topic = topic_fixture()
      assert Contens.get_topic!(topic.id) == topic
    end

    test "create_topic/1 with valid data creates a topic" do
      assert {:ok, %Topic{} = topic} = Contens.create_topic(@valid_attrs)
      assert topic.title == "some title"
    end

    test "create_topic/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contens.create_topic(@invalid_attrs)
    end

    test "update_topic/2 with valid data updates the topic" do
      topic = topic_fixture()
      assert {:ok, topic} = Contens.update_topic(topic, @update_attrs)
      assert %Topic{} = topic
      assert topic.title == "some updated title"
    end

    test "update_topic/2 with invalid data returns error changeset" do
      topic = topic_fixture()
      assert {:error, %Ecto.Changeset{}} = Contens.update_topic(topic, @invalid_attrs)
      assert topic == Contens.get_topic!(topic.id)
    end

    test "delete_topic/1 deletes the topic" do
      topic = topic_fixture()
      assert {:ok, %Topic{}} = Contens.delete_topic(topic)
      assert_raise Ecto.NoResultsError, fn -> Contens.get_topic!(topic.id) end
    end

    test "change_topic/1 returns a topic changeset" do
      topic = topic_fixture()
      assert %Ecto.Changeset{} = Contens.change_topic(topic)
    end
  end

  describe "cards" do
    alias Everlearn.Contens.Card

    @valid_attrs %{active: true, language: "some language", title: "some title"}
    @update_attrs %{active: false, language: "some updated language", title: "some updated title"}
    @invalid_attrs %{active: nil, language: nil, title: nil}

    def card_fixture(attrs \\ %{}) do
      {:ok, card} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contens.create_card()

      card
    end

    test "list_cards/0 returns all cards" do
      card = card_fixture()
      assert Contens.list_cards() == [card]
    end

    test "get_card!/1 returns the card with given id" do
      card = card_fixture()
      assert Contens.get_card!(card.id) == card
    end

    test "create_card/1 with valid data creates a card" do
      assert {:ok, %Card{} = card} = Contens.create_card(@valid_attrs)
      assert card.active == true
      assert card.language == "some language"
      assert card.title == "some title"
    end

    test "create_card/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contens.create_card(@invalid_attrs)
    end

    test "update_card/2 with valid data updates the card" do
      card = card_fixture()
      assert {:ok, card} = Contens.update_card(card, @update_attrs)
      assert %Card{} = card
      assert card.active == false
      assert card.language == "some updated language"
      assert card.title == "some updated title"
    end

    test "update_card/2 with invalid data returns error changeset" do
      card = card_fixture()
      assert {:error, %Ecto.Changeset{}} = Contens.update_card(card, @invalid_attrs)
      assert card == Contens.get_card!(card.id)
    end

    test "delete_card/1 deletes the card" do
      card = card_fixture()
      assert {:ok, %Card{}} = Contens.delete_card(card)
      assert_raise Ecto.NoResultsError, fn -> Contens.get_card!(card.id) end
    end

    test "change_card/1 returns a card changeset" do
      card = card_fixture()
      assert %Ecto.Changeset{} = Contens.change_card(card)
    end
  end
end

defmodule Everlearn.Contents do
  @moduledoc """
  The Contents context.
  """
  import Ecto.Query, warn: false
  import Everlearn.{CustomMethods}

  alias Everlearn.Repo
  alias Everlearn.Contents.{Pack, PackItem, Classroom, Item, Topic, Card}
  alias Everlearn.Members

# ------------------------- Shared functions ----------------------------------------


# ---------------------------- PACKS -------------------------------------------

  def pack_level_select_btn do
    [beginner: 1, advanced: 2, expert: 3]
  end

  def list_packs(params) do
    case Map.has_key?(params, "search") do
      true ->
        search_params = %{
          "search" => %{
            "title" => %{"assoc" => [], "search_type" => "ilike", "search_term" => params["search"]["title"]},
            "classroom_id" => %{"assoc" => [], "search_type" => "eq", "search_term" => params["search"]["classroom"]},
            "level" => %{"assoc" => [], "search_type" => "eq", "search_term" => params["search"]["level"]},
            "active" => %{"assoc" => [], "search_type" => "eq", "search_term" => params["search"]["active"]},
            "language_id" => %{"assoc" => [], "search_type" => "eq", "search_term" => params["search"]["language"]}
          }
        }
      false ->
        search_params = %{"title" => "", "classroom_id" => "", "level" => "", "active" => "", "language_id" => ""}
    end

    {search, rummage} = Pack
    |> Pack.rummage(search_params)
    IO.inspect(search_params)
    query = from pack in Pack,
      join: pi in assoc(pack, :packitems),
      join: item in assoc(pi, :item),
      where: item.active == true
    packs = search
    |> Repo.all()
    |> Repo.preload([:classroom, :language, items: query])
    # |> Enum.map(fn (pack) ->
    #   pack
    #   |> list_eligible_items()
    #   |> Enum.count()
    #   |> IO.inspect()
    # end)
    {packs, "rummage"}
  end

  def get_pack!(id) do
    Pack
    |> Repo.get!(id)
    |> Repo.preload([:classroom])
  end

  def create_pack(attrs \\ %{}) do
    %Pack{}
    |> Pack.changeset(attrs)
    |> Repo.insert()
  end

  def update_pack(%Pack{} = pack, attrs) do
    pack
    |> Pack.changeset(attrs)
    |> Repo.update()
  end

  def delete_pack(%Pack{} = pack) do
    Repo.delete(pack)
  end

  def change_pack(%Pack{} = pack) do
    Pack.changeset(pack, %{})
  end

# ------------------------ CLASSROOMS ------------------------------------------------

  def classroom_select_btn do
    Repo.all(from(c in Classroom, select: {c.title, c.id}))
  end

  def list_classrooms do
    Repo.all(Classroom)
    |> Repo.preload([:topics, :items, :packs])
  end

  def get_classroom!(id), do: Repo.get!(Classroom, id)

  def create_classroom(attrs \\ %{}) do
    %Classroom{}
    |> Classroom.changeset(attrs)
    |> Repo.insert()
  end

  def update_classroom(%Classroom{} = classroom, attrs) do
    classroom
    |> Classroom.changeset(attrs)
    |> Repo.update()
  end

  def delete_classroom(%Classroom{} = classroom) do
    Repo.delete(classroom)
  end

  def change_classroom(%Classroom{} = classroom) do
    Classroom.changeset(classroom, %{})
  end

# --------------------- ITEMS ----------------------------------------------------

  def item_group_select_btn do
    [verb: 1, noun: 2, date: 3]
  end

  @moduledoc """
  insert item with populated fields on a specific topic_id
  If item_id == "" -> create the item_id
  If item_id != "" && item_title != "" -> update the item
  Else fetch the item
  """
  def control_item_fields(item_level) do
    convert_integer(item_level)
  end

  def process_item_line(fields, topic_id) do
    %{:item_id => item_id, :item_title => item_title, :item_level => item_level, :item_group => item_group,
      :item_active => item_active, :item_description => item_description} = fields
    case control_item_fields(item_level) do
      {:error, _} ->
        {:error, "Insert item error : field problem on item with id = #{item_id}"}
      {:ok, _} ->
        cond do
          item_id == "" ->
            # It's a new item : try to create it
            Item.changeset(%Item{}, %{
              topic_id: topic_id,
              active: convert_boolean(item_active),
              description: item_description,
              group: item_group,
              level: String.to_integer(item_level),
              title: item_title
            })
            |> Repo.insert
          item_id != "" && (item_title != "") ->
            # It's an update item : try to update it
            Item.changeset(%Item{}, %{
              id: item_id,
              topic_id: topic_id,
              active: convert_boolean(item_active),
              description: item_description,
              group: item_group,
              level: String.to_integer(item_level),
              title: item_title
            })
            |> Repo.update
          item_id != "" ->
            # No change on the item : find it
            case get_item!(item_id) do
              {:ok, item} -> {:ok, item}
              {:error, _} -> {:error, "Couldnt find the item with id = #{item_id}"}
            end
        end
    end
  end

  # def list_items() do
  #   query = from c in Card, where: c.active == true
  #   Item
  #   |> Repo.all()
  #   |> Repo.preload([:packitems, :cards])
  #   # |> Repo.preload([topic: [:classroom], :cards])
  # end

  def list_items(_) do
    # query1 = from pi in PackItem,
    #   join: pack in assoc(pi, :pack)
    #   where: pack.active == true
    # query2 = from c in Card,
    #   where: c.active == true
    Item
    |> Repo.all()
    |> Repo.preload([topic: [:classroom]])
    |> Repo.preload([:cards, :packs])
    # |> Repo.preload([packs: query3])
    # |> Repo.preload([packitems: query1, cards: query2])
  end

  def list_eligible_items(pack) do
    p = pack
    |> Repo.preload(:classroom)
    # Select active items belonging to pack.classroom and having at least one card with language == pack.language
    query1 = from item in Item,
      join: topic in assoc(item, :topic),
      join: class in assoc(topic, :classroom),
      join: card in assoc(item, :cards),
      where: class.id == ^p.classroom.id,
      where: card.language_id == ^p.language_id,
      where: item.active == true,
      where: card.active == true,
      group_by: item.id,
      having: count(card.id) > 0
    # Select packitems associated to pack
    query2 = from pi in PackItem,
      where: pi.pack_id == ^pack.id
    query1
    |> Repo.all()
    |> Repo.preload([:topic, :cards, packitems: query2])
  end

  def choose_random_item(pack) do
    list_eligible_items(pack)
    |> Enum.random()
  end

  def get_item!(id), do: Repo.get!(Item, id)

  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  def change_item(%Item{} = item) do
    Item.changeset(item, %{})
  end

# -------------------------------- TOPICS ------------------------------------------

  def topic_select_btn do
    Repo.all(from(c in Topic, select: {c.title, c.id}))
  end

  def list_topics do
    Topic
    |> Repo.all()
    |> Repo.preload([:classroom, :items])
  end

  def get_topic!(id), do: Repo.get!(Topic, id)

  def create_topic(attrs \\ %{}) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Repo.insert()
  end

  def update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  def delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  def change_topic(%Topic{} = topic) do
    Topic.changeset(topic, %{})
  end

  # --------------------------- CARDS ----------------------------------------------

  @moduledoc """
  Treat a csv file line by line trying to insert cards
  """
  def import_cards(topic_id, file) do
    file
    |> File.stream!()
    |> CSV.decode(separator: ?;, headers: [
      :item_id, :item_group, :item_title, :item_level, :item_description, :item_active,
      :card_language, :card_title, :card_active
    ])
    |> Enum.map(fn (line) ->
      case insert_card_line(line, topic_id) do
          {:ok_card, card} -> IO.puts("Line #{"line_nb"} was processed")
          {:error_card, msg} -> IO.puts(msg)
          {:error_item, msg} -> IO.puts(msg)
          {:error_line, msg} -> IO.puts(msg)
      end
    end)
  end

  @moduledoc """
  Treat a csv file line by line trying to insert cards
  """
  defp insert_card_line(line, topic_id) do
    {status, fields} = line
    case status do
      :ok ->
        # This line is ok for decoding
        case process_item_line(fields, topic_id) do
          {:ok, item} ->
            # Item was processed (created, updated or fetched) : create the card with item_id
            %{:card_active => card_active, :card_language => iso2code, :card_title => card_title} = fields
            card = Card.changeset(%Card{}, %{
              item_id: item.id,
              active: convert_boolean(card_active),
              language_id: Members.get_language_by_code(iso2code).id,
              title: card_title
            })
            case Repo.insert(card) do
              {:ok, card} -> {:ok_card, card}
              {:error, msg} -> {:error_card, msg}
            end
          {:error, msg} -> {:error_item, msg}
        end
      :error ->
        # This line has a problem in decode
        %{:item_id => item_id, :item_title => item_title} = fields
        {:error_line, "some errors where found on item with ID = #{item_id} and title = #{item_title}"}
    end
  end

  def list_cards do
    query1 = from pi in PackItem,
      join: pack in assoc(pi, :pack),
      where: pack.active == true
    Card
    |> Repo.all()
    |> Repo.preload(:language)
    |> Repo.preload(item: [packitems: query1])
  end
  #
  # query1 = from pi in PackItem,
  #   join: pack in assoc(pi, :pack),
  #   where: pack.active == true
  # query2 = from c in Card, where: c.active == true
  # Item
  # |> Repo.all()
  # |> Repo.preload([topic: [:classroom]])
  # |> Repo.preload([packitems: query1, cards: query2])

  def get_card!(id), do: Repo.get!(Card, id)

  def create_card(attrs \\ %{}) do
    %Card{}
    |> Card.changeset(attrs)
    |> Repo.insert()
  end

  def update_card(%Card{} = card, attrs) do
    card
    |> Card.changeset(attrs)
    |> Repo.update()
  end

  def delete_card(%Card{} = card) do
    Repo.delete(card)
  end

  def change_card(%Card{} = card) do
    Card.changeset(card, %{})
  end

  # ------------------------- PACKITEMS ----------------------------------------------

  def generate_pack_items(pack) do
    pack
    |> choose_random_item()
    |> Ecto.build_assoc(:packitems, %{pack_id: pack.id})
    |> Repo.insert!()
  end

  def toogle_pack_item(item_id, pack_id) do
    case get_pack_item(item_id, pack_id) do
      %PackItem{} = pack_item ->
        # There is allready a PackItem : delete it
        case delete_pack_item(pack_item) do
          {:ok, pack_item} -> {:deleted, pack_item}
          {:error, reason} -> {:error, reason}
        end
      nil ->
        # There wasnt any PackItem : create it
        case create_pack_item(%{item_id: item_id, pack_id: pack_id}) do
          {:ok, pack_item} -> {:created, pack_item}
          {:error, reason} -> {:error, reason}
        end
    end
  end

  def get_pack_item(item_id, pack_id) do
    query = from p in PackItem,
      where: p.item_id == ^item_id and p.pack_id == ^pack_id,
      select: p
    Repo.one(query)
  end

  def create_pack_item(attrs \\ %{}) do
    %PackItem{}
    |> PackItem.changeset(attrs)
    |> Repo.insert()
  end

  def delete_pack_item(%PackItem{} = pack_item) do
    Repo.delete(pack_item)
  end

  def change_pack_item(%PackItem{} = pack_item) do
    PackItem.changeset(pack_item, %{})
  end
end

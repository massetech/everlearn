# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Everlearn.Repo.insert!(%Everlearn.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Everlearn.Repo
alias Everlearn.Contents.{Classroom, Topic, Item, Card, Pack, PackItem, Kind}
alias Everlearn.Members
alias Everlearn.Members.{Language, User}

Repo.delete_all(Classroom)
Repo.delete_all(Topic)
Repo.delete_all(Item)
Repo.delete_all(Card)
Repo.delete_all(Pack)
Repo.delete_all(PackItem)
Repo.delete_all(Language)
Repo.delete_all(User)
Repo.delete_all(Kind)

# Generate languages
Repo.insert! %Language{name: "English", iso2code: "en"}
Repo.insert! %Language{name: "French", iso2code: "fr"}
Repo.insert! %Language{name: "Spanish", iso2code: "es"}
Repo.insert! %Language{name: "Burmese", iso2code: "mm"}

# Generate classrooms
Repo.insert! %Classroom{title: "Language"}

Repo.insert! %Kind{name: "noun"}
Repo.insert! %Kind{name: "verb"}
Repo.insert! %Kind{name: "event"}
# for kind <- ["noun", "event", "verb"] do
#   Repo.insert! %Kind{name: kind}
# end

# Generate topics
for classroom <- Repo.all(Classroom) do
  for i <- 1..3 do
    topic = Ecto.build_assoc(classroom, :topics, %{title: "Topic_#{i}"})
      #Topic.changeset(%Topic{}, %{classroom_id: classroom.id, title: "Topic_#{i}"})
    |> Repo.insert!()
  end
end

# # Generate Items
# for topic <- Repo.all(Topic) do
#   Contents.import_items(topic.id, Path.expand("priv/repo/seeds-items.csv"))
# end

# # Generate cards
# for topic <- Repo.all(Topic) do
#   Contents.import_cards(topic.id, Path.expand("priv/repo/seeds-cards.csv"))
# end

# Generate packs
for classroom <- Repo.all(Classroom) do
  for i <- 1..5 do
    pack = Ecto.build_assoc(classroom, :packs, %{title: "Pack_title_#{i}", level: Enum.random([1, 2, 3]), language_id: Members.choose_random_language().id})
    |> Repo.insert!()
    # |> Contents.generate_pack_items()
  end
end

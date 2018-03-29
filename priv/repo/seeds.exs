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
alias Everlearn.Contents.{Classroom, Topic, Item, Card, Pack, PackItem, Kind, PackLanguage}
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
Repo.insert! %Language{title: "English", iso2code: "en"}
Repo.insert! %Language{title: "French", iso2code: "fr"}
Repo.insert! %Language{title: "Burmese", iso2code: "mm"}
Repo.insert! %Language{title: "Chinese", iso2code: "cn"}
# Repo.insert! %Language{name: "Spanish", iso2code: "es"}
# Repo.insert! %Language{name: "Thaï", iso2code: "th"}
# Repo.insert! %Language{name: "Portuguese", iso2code: "pt"}

# Generate classrooms
Repo.insert! %Classroom{title: "Vocabulary", mono_language: false}
Repo.insert! %Classroom{title: "Grammar"}
Repo.insert! %Classroom{title: "History"}

# Generate kinds
for kind <- ["noun", "event", "verb"] do
  Repo.insert! %Kind{title: kind}
end

# Generate topics
# Topic.changeset(%Topic{}, %{classroom_id: classroom.id, title: "Topic_#{i}"})
for i <- ["General", "Cooking", "Sport"] do
  # topic = Ecto.build_assoc(classroom, :topics, %{title: i})
  Repo.insert! %Topic{title: i}
end

items = [
  %Item{title: "to be", level: 1, description: "any", active: true, topic_id: 1, kind_id: 1, classroom_id: 1},
  %Item{title: "house", level: 1, description: "any", active: true, topic_id: 1, kind_id: 1, classroom_id: 1},
  %Item{title: "dog", level: 1, description: "any", active: true, topic_id: 1, kind_id: 1, classroom_id: 1},
  %Item{title: "cat", level: 1, description: "any", active: true, topic_id: 1, kind_id: 1, classroom_id: 1},
  %Item{title: "to sleep", level: 1, description: "any", active: true, topic_id: 1, kind_id: 1, classroom_id: 1}
]

packs = [
  %Pack{classroom_id: 1, title: "Must know words", level: 1, active: true, description: "any"},
  %Pack{classroom_id: 1, title: "Must know verbs", level: 2, active: true, description: "any"},
  %Pack{classroom_id: 1, title: "Must know nouns", level: 3, active: true, description: "any"}
]

packitems = [
  %PackItem{pack_id: 1,item_id: 1},
  %PackItem{pack_id: 1,item_id: 2},
  %PackItem{pack_id: 1,item_id: 3},
  %PackItem{pack_id: 1,item_id: 4},
  %PackItem{pack_id: 1,item_id: 5},
  %PackItem{pack_id: 2,item_id: 1},
  %PackItem{pack_id: 2,item_id: 5},
  %PackItem{pack_id: 3,item_id: 2},
  %PackItem{pack_id: 3,item_id: 3},
  %PackItem{pack_id: 3,item_id: 4}
]

packlanguages = [
  %PackLanguage{pack_id: 1, language_id: 1, title: "Must know words"},
  %PackLanguage{pack_id: 1, language_id: 2, title: "Mots à connaître"},
  %PackLanguage{pack_id: 1, language_id: 3, title: "စ်ိုစရ်ပစရဗပ်ိစပ"},
  %PackLanguage{pack_id: 2, language_id: 1, title: "Must know verbs"},
  %PackLanguage{pack_id: 2, language_id: 2, title: "Verbes à connaître"},
  %PackLanguage{pack_id: 2, language_id: 3, title: "စ်ိုစရ်ပစရဗပ်ိစပ"},
  %PackLanguage{pack_id: 3, language_id: 1, title: "Must know nouns"},
  %PackLanguage{pack_id: 3, language_id: 2, title: "Noms communs à connaître"},
  %PackLanguage{pack_id: 3, language_id: 3, title: "စ်ိုစရ်ပစရဗပ်ိစပ"},
]

cards_english = [
  %Card{item_id: 1, question: "to be", answer: "", active: true, language_id: 1},
  %Card{item_id: 2, question: "house", answer: "", active: true, language_id: 1},
  %Card{item_id: 3, question: "dog", answer: "", active: true, language_id: 1},
  %Card{item_id: 4, question: "cat", answer: "", active: true, language_id: 1},
  %Card{item_id: 5, question: "to sleep", answer: "", active: true, language_id: 1}
]

cards_french = [
  %Card{item_id: 1, question: "être", answer: "", active: true, language_id: 2},
  %Card{item_id: 2, question: "la maison", answer: "", active: true, language_id: 2},
  %Card{item_id: 3, question: "le chien", answer: "", active: true, language_id: 2},
  %Card{item_id: 4, question: "le chat", answer: "", active: true, language_id: 2},
  %Card{item_id: 5, question: "dormir", answer: "", active: true, language_id: 2}
]

cards_burmese = [
  %Card{item_id: 1, question: "ပြက်", answer: "", active: true, language_id: 3},
  %Card{item_id: 2, question: "အိုင်", answer: "", active: true, language_id: 3},
  %Card{item_id: 3, question: "ခွေး", answer: "", active: true, language_id: 3},
  %Card{item_id: 4, question: "မြော်", answer: "", active: true, language_id: 3},
  %Card{item_id: 5, question: "အိ္", answer: "", active: true, language_id: 3}
]

for i <- items do Repo.insert!(i) end
for p <- packs do Repo.insert!(p) end
for pi <- packitems do Repo.insert!(pi) end
for pl <- packlanguages do Repo.insert!(pl) end
for c <- cards_english do Repo.insert!(c) end
for c <- cards_french do Repo.insert!(c) end
for c <- cards_burmese do Repo.insert!(c) end

# Generate Items
# Contents.import_items(topic.id, Path.expand("priv/repo/seeds-items.csv"))
# for i <- 1..30 do
#   random_kind = Enum.random(Repo.all(Kind))
#   random_classroom = Enum.random(Repo.all(Classroom))
#   random_topic = Enum.random(Repo.all(Topic))
#   Repo.insert! %Item{title: "#item_#{i}", level: Enum.random([1, 2, 3]),
#     description: "description", active: Enum.random([false, true]),
#     topic_id: random_topic.id, kind_id: random_kind.id, classroom_id: random_classroom.id}
# end

# Generate cards
# Contents.import_cards(topic.id, Path.expand("priv/repo/seeds-cards.csv"))
# for item <- Repo.all(Item) do
#   for i <- 1..5 do
#     random_language = Enum.random(Repo.all(Language))
#     Repo.insert! %Card{question: "question #{i}", answer: "answer #{i}", active: Enum.random([false, true]),
#     item_id: item.id, language_id: random_language.id}
#   end
# end

# # Generate packs
# for classroom <- Repo.all(Classroom) do
#   for i <- 1..5 do
#     Repo.insert! %Pack{
#       classroom_id: classroom.id, title: "Pack_title_#{i}",
#       level: Enum.random([1, 2, 3]), active: Enum.random([false, true]),
#       description: "description",
#     }
#   end
# end

# Generate packlanguages
# for pack <- Repo.all(Pack) do
#   for language <- Enum.take_random(Repo.all(Language), 3) do
#     Repo.insert! %PackLanguage{pack_id: pack.id, language_id: language.id, title: "Title_#{language.iso2code}"}
#   end
# end

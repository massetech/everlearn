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
alias Everlearn.Contents
alias Everlearn.Contents.{Classroom, Topic}

Repo.insert! %Classroom{title: "History"}
Repo.insert! %Classroom{title: "Language"}
Repo.insert! %Classroom{title: "Geography"}
Repo.insert! %Classroom{title: "Culture"}

for classroom <- Repo.all(Classroom) do
  for i <- 1..5 do
    topic = Ecto.build_assoc(classroom, :topics, %{title: "Topic_#{i}"})
      #Topic.changeset(%Topic{}, %{classroom_id: classroom.id, title: "Topic_#{i}"})
    |> Repo.insert!()
  end
end

for topic <- Repo.all(Topic) do
  Contents.upload_cards(topic.id, Path.expand("priv/repo/seeds-cards.csv"))
end

for classroom <- Repo.all(Classroom) do
  for i <- 1..5 do
    pack = Ecto.build_assoc(classroom, :packs, %{title: "Pack_title_#{i}", level: Enum.random([1, 2, 3])})
    |> Repo.insert!()
    |> Contents.generate_pack_items()
  end
end

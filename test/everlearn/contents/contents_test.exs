defmodule Everlearn.ContentsTest do
  use Everlearn.DataCase

  alias Everlearn.Contents

  describe "packs" do
    alias Everlearn.Contents.Pack

    @valid_attrs %{active: true, level: 42, title: "some title"}
    @update_attrs %{active: false, level: 43, title: "some updated title"}
    @invalid_attrs %{active: nil, level: nil, title: nil}

    def pack_fixture(attrs \\ %{}) do
      {:ok, pack} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contents.create_pack()

      pack
    end

    test "list_packs/0 returns all packs" do
      pack = pack_fixture()
      assert Contents.list_packs() == [pack]
    end

    test "get_pack!/1 returns the pack with given id" do
      pack = pack_fixture()
      assert Contents.get_pack!(pack.id) == pack
    end

    test "create_pack/1 with valid data creates a pack" do
      assert {:ok, %Pack{} = pack} = Contents.create_pack(@valid_attrs)
      assert pack.active == true
      assert pack.level == 42
      assert pack.title == "some title"
    end

    test "create_pack/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contents.create_pack(@invalid_attrs)
    end

    test "update_pack/2 with valid data updates the pack" do
      pack = pack_fixture()
      assert {:ok, pack} = Contents.update_pack(pack, @update_attrs)
      assert %Pack{} = pack
      assert pack.active == false
      assert pack.level == 43
      assert pack.title == "some updated title"
    end

    test "update_pack/2 with invalid data returns error changeset" do
      pack = pack_fixture()
      assert {:error, %Ecto.Changeset{}} = Contents.update_pack(pack, @invalid_attrs)
      assert pack == Contents.get_pack!(pack.id)
    end

    test "delete_pack/1 deletes the pack" do
      pack = pack_fixture()
      assert {:ok, %Pack{}} = Contents.delete_pack(pack)
      assert_raise Ecto.NoResultsError, fn -> Contents.get_pack!(pack.id) end
    end

    test "change_pack/1 returns a pack changeset" do
      pack = pack_fixture()
      assert %Ecto.Changeset{} = Contents.change_pack(pack)
    end
  end

  describe "classrooms" do
    alias Everlearn.Contents.Classroom

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def classroom_fixture(attrs \\ %{}) do
      {:ok, classroom} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contents.create_classroom()

      classroom
    end

    test "list_classrooms/0 returns all classrooms" do
      classroom = classroom_fixture()
      assert Contents.list_classrooms() == [classroom]
    end

    test "get_classroom!/1 returns the classroom with given id" do
      classroom = classroom_fixture()
      assert Contents.get_classroom!(classroom.id) == classroom
    end

    test "create_classroom/1 with valid data creates a classroom" do
      assert {:ok, %Classroom{} = classroom} = Contents.create_classroom(@valid_attrs)
      assert classroom.title == "some title"
    end

    test "create_classroom/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contents.create_classroom(@invalid_attrs)
    end

    test "update_classroom/2 with valid data updates the classroom" do
      classroom = classroom_fixture()
      assert {:ok, classroom} = Contents.update_classroom(classroom, @update_attrs)
      assert %Classroom{} = classroom
      assert classroom.title == "some updated title"
    end

    test "update_classroom/2 with invalid data returns error changeset" do
      classroom = classroom_fixture()
      assert {:error, %Ecto.Changeset{}} = Contents.update_classroom(classroom, @invalid_attrs)
      assert classroom == Contents.get_classroom!(classroom.id)
    end

    test "delete_classroom/1 deletes the classroom" do
      classroom = classroom_fixture()
      assert {:ok, %Classroom{}} = Contents.delete_classroom(classroom)
      assert_raise Ecto.NoResultsError, fn -> Contents.get_classroom!(classroom.id) end
    end

    test "change_classroom/1 returns a classroom changeset" do
      classroom = classroom_fixture()
      assert %Ecto.Changeset{} = Contents.change_classroom(classroom)
    end
  end

  describe "items" do
    alias Everlearn.Contents.Item

    @valid_attrs %{active: true, description: "some description", group: "some group", level: 42, title: "some title"}
    @update_attrs %{active: false, description: "some updated description", group: "some updated group", level: 43, title: "some updated title"}
    @invalid_attrs %{active: nil, description: nil, group: nil, level: nil, title: nil}

    def item_fixture(attrs \\ %{}) do
      {:ok, item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contents.create_item()

      item
    end

    test "list_items/0 returns all items" do
      item = item_fixture()
      assert Contents.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id" do
      item = item_fixture()
      assert Contents.get_item!(item.id) == item
    end

    test "create_item/1 with valid data creates a item" do
      assert {:ok, %Item{} = item} = Contents.create_item(@valid_attrs)
      assert item.active == true
      assert item.description == "some description"
      assert item.group == "some group"
      assert item.level == 42
      assert item.title == "some title"
    end

    test "create_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contents.create_item(@invalid_attrs)
    end

    test "update_item/2 with valid data updates the item" do
      item = item_fixture()
      assert {:ok, item} = Contents.update_item(item, @update_attrs)
      assert %Item{} = item
      assert item.active == false
      assert item.description == "some updated description"
      assert item.group == "some updated group"
      assert item.level == 43
      assert item.title == "some updated title"
    end

    test "update_item/2 with invalid data returns error changeset" do
      item = item_fixture()
      assert {:error, %Ecto.Changeset{}} = Contents.update_item(item, @invalid_attrs)
      assert item == Contents.get_item!(item.id)
    end

    test "delete_item/1 deletes the item" do
      item = item_fixture()
      assert {:ok, %Item{}} = Contents.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Contents.get_item!(item.id) end
    end

    test "change_item/1 returns a item changeset" do
      item = item_fixture()
      assert %Ecto.Changeset{} = Contents.change_item(item)
    end
  end

  describe "packitems" do
    alias Everlearn.Contents.PackItem

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def pack_item_fixture(attrs \\ %{}) do
      {:ok, pack_item} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contents.create_pack_item()

      pack_item
    end

    test "list_packitems/0 returns all packitems" do
      pack_item = pack_item_fixture()
      assert Contents.list_packitems() == [pack_item]
    end

    test "get_pack_item!/1 returns the pack_item with given id" do
      pack_item = pack_item_fixture()
      assert Contents.get_pack_item!(pack_item.id) == pack_item
    end

    test "create_pack_item/1 with valid data creates a pack_item" do
      assert {:ok, %PackItem{} = pack_item} = Contents.create_pack_item(@valid_attrs)
    end

    test "create_pack_item/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contents.create_pack_item(@invalid_attrs)
    end

    test "update_pack_item/2 with valid data updates the pack_item" do
      pack_item = pack_item_fixture()
      assert {:ok, pack_item} = Contents.update_pack_item(pack_item, @update_attrs)
      assert %PackItem{} = pack_item
    end

    test "update_pack_item/2 with invalid data returns error changeset" do
      pack_item = pack_item_fixture()
      assert {:error, %Ecto.Changeset{}} = Contents.update_pack_item(pack_item, @invalid_attrs)
      assert pack_item == Contents.get_pack_item!(pack_item.id)
    end

    test "delete_pack_item/1 deletes the pack_item" do
      pack_item = pack_item_fixture()
      assert {:ok, %PackItem{}} = Contents.delete_pack_item(pack_item)
      assert_raise Ecto.NoResultsError, fn -> Contents.get_pack_item!(pack_item.id) end
    end

    test "change_pack_item/1 returns a pack_item changeset" do
      pack_item = pack_item_fixture()
      assert %Ecto.Changeset{} = Contents.change_pack_item(pack_item)
    end
  end

  describe "kinds" do
    alias Everlearn.Contents.Kind

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def kind_fixture(attrs \\ %{}) do
      {:ok, kind} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contents.create_kind()

      kind
    end

    test "list_kinds/0 returns all kinds" do
      kind = kind_fixture()
      assert Contents.list_kinds() == [kind]
    end

    test "get_kind!/1 returns the kind with given id" do
      kind = kind_fixture()
      assert Contents.get_kind!(kind.id) == kind
    end

    test "create_kind/1 with valid data creates a kind" do
      assert {:ok, %Kind{} = kind} = Contents.create_kind(@valid_attrs)
      assert kind.name == "some name"
    end

    test "create_kind/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contents.create_kind(@invalid_attrs)
    end

    test "update_kind/2 with valid data updates the kind" do
      kind = kind_fixture()
      assert {:ok, kind} = Contents.update_kind(kind, @update_attrs)
      assert %Kind{} = kind
      assert kind.name == "some updated name"
    end

    test "update_kind/2 with invalid data returns error changeset" do
      kind = kind_fixture()
      assert {:error, %Ecto.Changeset{}} = Contents.update_kind(kind, @invalid_attrs)
      assert kind == Contents.get_kind!(kind.id)
    end

    test "delete_kind/1 deletes the kind" do
      kind = kind_fixture()
      assert {:ok, %Kind{}} = Contents.delete_kind(kind)
      assert_raise Ecto.NoResultsError, fn -> Contents.get_kind!(kind.id) end
    end

    test "change_kind/1 returns a kind changeset" do
      kind = kind_fixture()
      assert %Ecto.Changeset{} = Contents.change_kind(kind)
    end
  end

  describe "packlanguages" do
    alias Everlearn.Contents.Packlanguage

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def packlanguage_fixture(attrs \\ %{}) do
      {:ok, packlanguage} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Contents.create_packlanguage()

      packlanguage
    end

    test "list_packlanguages/0 returns all packlanguages" do
      packlanguage = packlanguage_fixture()
      assert Contents.list_packlanguages() == [packlanguage]
    end

    test "get_packlanguage!/1 returns the packlanguage with given id" do
      packlanguage = packlanguage_fixture()
      assert Contents.get_packlanguage!(packlanguage.id) == packlanguage
    end

    test "create_packlanguage/1 with valid data creates a packlanguage" do
      assert {:ok, %Packlanguage{} = packlanguage} = Contents.create_packlanguage(@valid_attrs)
    end

    test "create_packlanguage/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Contents.create_packlanguage(@invalid_attrs)
    end

    test "update_packlanguage/2 with valid data updates the packlanguage" do
      packlanguage = packlanguage_fixture()
      assert {:ok, packlanguage} = Contents.update_packlanguage(packlanguage, @update_attrs)
      assert %Packlanguage{} = packlanguage
    end

    test "update_packlanguage/2 with invalid data returns error changeset" do
      packlanguage = packlanguage_fixture()
      assert {:error, %Ecto.Changeset{}} = Contents.update_packlanguage(packlanguage, @invalid_attrs)
      assert packlanguage == Contents.get_packlanguage!(packlanguage.id)
    end

    test "delete_packlanguage/1 deletes the packlanguage" do
      packlanguage = packlanguage_fixture()
      assert {:ok, %Packlanguage{}} = Contents.delete_packlanguage(packlanguage)
      assert_raise Ecto.NoResultsError, fn -> Contents.get_packlanguage!(packlanguage.id) end
    end

    test "change_packlanguage/1 returns a packlanguage changeset" do
      packlanguage = packlanguage_fixture()
      assert %Ecto.Changeset{} = Contents.change_packlanguage(packlanguage)
    end
  end
end

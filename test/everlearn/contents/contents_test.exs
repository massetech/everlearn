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
end

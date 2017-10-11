defmodule Everlearn.MembersTest do
  use Everlearn.DataCase

  alias Everlearn.Members

  describe "users" do
    alias Everlearn.Members.User

    @valid_attrs %{email: "some email", main_language: "some main_language", provider: "some provider", role: "some role", token: "some token"}
    @update_attrs %{email: "some updated email", main_language: "some updated main_language", provider: "some updated provider", role: "some updated role", token: "some updated token"}
    @invalid_attrs %{email: nil, main_language: nil, provider: nil, role: nil, token: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Members.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Members.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Members.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = Members.create_user(@valid_attrs)
      assert user.email == "some email"
      assert user.main_language == "some main_language"
      assert user.provider == "some provider"
      assert user.role == "some role"
      assert user.token == "some token"
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Members.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, user} = Members.update_user(user, @update_attrs)
      assert %User{} = user
      assert user.email == "some updated email"
      assert user.main_language == "some updated main_language"
      assert user.provider == "some updated provider"
      assert user.role == "some updated role"
      assert user.token == "some updated token"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Members.update_user(user, @invalid_attrs)
      assert user == Members.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Members.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Members.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Members.change_user(user)
    end
  end

  describe "memberships" do
    alias Everlearn.Members.Membership

    @valid_attrs %{language: "some language"}
    @update_attrs %{language: "some updated language"}
    @invalid_attrs %{language: nil}

    def membership_fixture(attrs \\ %{}) do
      {:ok, membership} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Members.create_membership()

      membership
    end

    test "list_memberships/0 returns all memberships" do
      membership = membership_fixture()
      assert Members.list_memberships() == [membership]
    end

    test "get_membership!/1 returns the membership with given id" do
      membership = membership_fixture()
      assert Members.get_membership!(membership.id) == membership
    end

    test "create_membership/1 with valid data creates a membership" do
      assert {:ok, %Membership{} = membership} = Members.create_membership(@valid_attrs)
      assert membership.language == "some language"
    end

    test "create_membership/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Members.create_membership(@invalid_attrs)
    end

    test "update_membership/2 with valid data updates the membership" do
      membership = membership_fixture()
      assert {:ok, membership} = Members.update_membership(membership, @update_attrs)
      assert %Membership{} = membership
      assert membership.language == "some updated language"
    end

    test "update_membership/2 with invalid data returns error changeset" do
      membership = membership_fixture()
      assert {:error, %Ecto.Changeset{}} = Members.update_membership(membership, @invalid_attrs)
      assert membership == Members.get_membership!(membership.id)
    end

    test "delete_membership/1 deletes the membership" do
      membership = membership_fixture()
      assert {:ok, %Membership{}} = Members.delete_membership(membership)
      assert_raise Ecto.NoResultsError, fn -> Members.get_membership!(membership.id) end
    end

    test "change_membership/1 returns a membership changeset" do
      membership = membership_fixture()
      assert %Ecto.Changeset{} = Members.change_membership(membership)
    end
  end

  describe "memorys" do
    alias Everlearn.Members.Memory

    @valid_attrs %{status: 42}
    @update_attrs %{status: 43}
    @invalid_attrs %{status: nil}

    def memory_fixture(attrs \\ %{}) do
      {:ok, memory} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Members.create_memory()

      memory
    end

    test "list_memorys/0 returns all memorys" do
      memory = memory_fixture()
      assert Members.list_memorys() == [memory]
    end

    test "get_memory!/1 returns the memory with given id" do
      memory = memory_fixture()
      assert Members.get_memory!(memory.id) == memory
    end

    test "create_memory/1 with valid data creates a memory" do
      assert {:ok, %Memory{} = memory} = Members.create_memory(@valid_attrs)
      assert memory.status == 42
    end

    test "create_memory/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Members.create_memory(@invalid_attrs)
    end

    test "update_memory/2 with valid data updates the memory" do
      memory = memory_fixture()
      assert {:ok, memory} = Members.update_memory(memory, @update_attrs)
      assert %Memory{} = memory
      assert memory.status == 43
    end

    test "update_memory/2 with invalid data returns error changeset" do
      memory = memory_fixture()
      assert {:error, %Ecto.Changeset{}} = Members.update_memory(memory, @invalid_attrs)
      assert memory == Members.get_memory!(memory.id)
    end

    test "delete_memory/1 deletes the memory" do
      memory = memory_fixture()
      assert {:ok, %Memory{}} = Members.delete_memory(memory)
      assert_raise Ecto.NoResultsError, fn -> Members.get_memory!(memory.id) end
    end

    test "change_memory/1 returns a memory changeset" do
      memory = memory_fixture()
      assert %Ecto.Changeset{} = Members.change_memory(memory)
    end
  end
end

defmodule EverlearnWeb.GroupControllerTest do
  use EverlearnWeb.ConnCase

  alias Everlearn.Groups

  @create_attrs %{active: true, kind: "some kind", level: 42, title: "some title"}
  @update_attrs %{active: false, kind: "some updated kind", level: 43, title: "some updated title"}
  @invalid_attrs %{active: nil, kind: nil, level: nil, title: nil}

  def fixture(:group) do
    {:ok, group} = Groups.create_group(@create_attrs)
    group
  end

  describe "index" do
    test "lists all groups", %{conn: conn} do
      conn = get conn, group_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Groups"
    end
  end

  describe "new group" do
    test "renders form", %{conn: conn} do
      conn = get conn, group_path(conn, :new)
      assert html_response(conn, 200) =~ "New Group"
    end
  end

  describe "create group" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, group_path(conn, :create), group: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == group_path(conn, :show, id)

      conn = get conn, group_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Group"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, group_path(conn, :create), group: @invalid_attrs
      assert html_response(conn, 200) =~ "New Group"
    end
  end

  describe "edit group" do
    setup [:create_group]

    test "renders form for editing chosen group", %{conn: conn, group: group} do
      conn = get conn, group_path(conn, :edit, group)
      assert html_response(conn, 200) =~ "Edit Group"
    end
  end

  describe "update group" do
    setup [:create_group]

    test "redirects when data is valid", %{conn: conn, group: group} do
      conn = put conn, group_path(conn, :update, group), group: @update_attrs
      assert redirected_to(conn) == group_path(conn, :show, group)

      conn = get conn, group_path(conn, :show, group)
      assert html_response(conn, 200) =~ "some updated kind"
    end

    test "renders errors when data is invalid", %{conn: conn, group: group} do
      conn = put conn, group_path(conn, :update, group), group: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Group"
    end
  end

  describe "delete group" do
    setup [:create_group]

    test "deletes chosen group", %{conn: conn, group: group} do
      conn = delete conn, group_path(conn, :delete, group)
      assert redirected_to(conn) == group_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, group_path(conn, :show, group)
      end
    end
  end

  defp create_group(_) do
    group = fixture(:group)
    {:ok, group: group}
  end
end

defmodule EverlearnWeb.KindControllerTest do
  use EverlearnWeb.ConnCase

  alias Everlearn.Contents

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:kind) do
    {:ok, kind} = Contents.create_kind(@create_attrs)
    kind
  end

  describe "index" do
    test "lists all kinds", %{conn: conn} do
      conn = get conn, kind_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Kinds"
    end
  end

  describe "new kind" do
    test "renders form", %{conn: conn} do
      conn = get conn, kind_path(conn, :new)
      assert html_response(conn, 200) =~ "New Kind"
    end
  end

  describe "create kind" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, kind_path(conn, :create), kind: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == kind_path(conn, :show, id)

      conn = get conn, kind_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Kind"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, kind_path(conn, :create), kind: @invalid_attrs
      assert html_response(conn, 200) =~ "New Kind"
    end
  end

  describe "edit kind" do
    setup [:create_kind]

    test "renders form for editing chosen kind", %{conn: conn, kind: kind} do
      conn = get conn, kind_path(conn, :edit, kind)
      assert html_response(conn, 200) =~ "Edit Kind"
    end
  end

  describe "update kind" do
    setup [:create_kind]

    test "redirects when data is valid", %{conn: conn, kind: kind} do
      conn = put conn, kind_path(conn, :update, kind), kind: @update_attrs
      assert redirected_to(conn) == kind_path(conn, :show, kind)

      conn = get conn, kind_path(conn, :show, kind)
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, kind: kind} do
      conn = put conn, kind_path(conn, :update, kind), kind: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Kind"
    end
  end

  describe "delete kind" do
    setup [:create_kind]

    test "deletes chosen kind", %{conn: conn, kind: kind} do
      conn = delete conn, kind_path(conn, :delete, kind)
      assert redirected_to(conn) == kind_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, kind_path(conn, :show, kind)
      end
    end
  end

  defp create_kind(_) do
    kind = fixture(:kind)
    {:ok, kind: kind}
  end
end

defmodule EverlearnWeb.ClassroomControllerTest do
  use EverlearnWeb.ConnCase

  alias Everlearn.Contents

  @create_attrs %{title: "some title"}
  @update_attrs %{title: "some updated title"}
  @invalid_attrs %{title: nil}

  def fixture(:classroom) do
    {:ok, classroom} = Contents.create_classroom(@create_attrs)
    classroom
  end

  describe "index" do
    test "lists all classrooms", %{conn: conn} do
      conn = get conn, classroom_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Classrooms"
    end
  end

  describe "new classroom" do
    test "renders form", %{conn: conn} do
      conn = get conn, classroom_path(conn, :new)
      assert html_response(conn, 200) =~ "New Classroom"
    end
  end

  describe "create classroom" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, classroom_path(conn, :create), classroom: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == classroom_path(conn, :show, id)

      conn = get conn, classroom_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Classroom"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, classroom_path(conn, :create), classroom: @invalid_attrs
      assert html_response(conn, 200) =~ "New Classroom"
    end
  end

  describe "edit classroom" do
    setup [:create_classroom]

    test "renders form for editing chosen classroom", %{conn: conn, classroom: classroom} do
      conn = get conn, classroom_path(conn, :edit, classroom)
      assert html_response(conn, 200) =~ "Edit Classroom"
    end
  end

  describe "update classroom" do
    setup [:create_classroom]

    test "redirects when data is valid", %{conn: conn, classroom: classroom} do
      conn = put conn, classroom_path(conn, :update, classroom), classroom: @update_attrs
      assert redirected_to(conn) == classroom_path(conn, :show, classroom)

      conn = get conn, classroom_path(conn, :show, classroom)
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, classroom: classroom} do
      conn = put conn, classroom_path(conn, :update, classroom), classroom: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Classroom"
    end
  end

  describe "delete classroom" do
    setup [:create_classroom]

    test "deletes chosen classroom", %{conn: conn, classroom: classroom} do
      conn = delete conn, classroom_path(conn, :delete, classroom)
      assert redirected_to(conn) == classroom_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, classroom_path(conn, :show, classroom)
      end
    end
  end

  defp create_classroom(_) do
    classroom = fixture(:classroom)
    {:ok, classroom: classroom}
  end
end

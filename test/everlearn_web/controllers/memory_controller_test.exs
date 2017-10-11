defmodule EverlearnWeb.MemoryControllerTest do
  use EverlearnWeb.ConnCase

  alias Everlearn.Members

  @create_attrs %{status: 42}
  @update_attrs %{status: 43}
  @invalid_attrs %{status: nil}

  def fixture(:memory) do
    {:ok, memory} = Members.create_memory(@create_attrs)
    memory
  end

  describe "index" do
    test "lists all memorys", %{conn: conn} do
      conn = get conn, memory_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Memorys"
    end
  end

  describe "new memory" do
    test "renders form", %{conn: conn} do
      conn = get conn, memory_path(conn, :new)
      assert html_response(conn, 200) =~ "New Memory"
    end
  end

  describe "create memory" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, memory_path(conn, :create), memory: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == memory_path(conn, :show, id)

      conn = get conn, memory_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Memory"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, memory_path(conn, :create), memory: @invalid_attrs
      assert html_response(conn, 200) =~ "New Memory"
    end
  end

  describe "edit memory" do
    setup [:create_memory]

    test "renders form for editing chosen memory", %{conn: conn, memory: memory} do
      conn = get conn, memory_path(conn, :edit, memory)
      assert html_response(conn, 200) =~ "Edit Memory"
    end
  end

  describe "update memory" do
    setup [:create_memory]

    test "redirects when data is valid", %{conn: conn, memory: memory} do
      conn = put conn, memory_path(conn, :update, memory), memory: @update_attrs
      assert redirected_to(conn) == memory_path(conn, :show, memory)

      conn = get conn, memory_path(conn, :show, memory)
      assert html_response(conn, 200)
    end

    test "renders errors when data is invalid", %{conn: conn, memory: memory} do
      conn = put conn, memory_path(conn, :update, memory), memory: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Memory"
    end
  end

  describe "delete memory" do
    setup [:create_memory]

    test "deletes chosen memory", %{conn: conn, memory: memory} do
      conn = delete conn, memory_path(conn, :delete, memory)
      assert redirected_to(conn) == memory_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, memory_path(conn, :show, memory)
      end
    end
  end

  defp create_memory(_) do
    memory = fixture(:memory)
    {:ok, memory: memory}
  end
end

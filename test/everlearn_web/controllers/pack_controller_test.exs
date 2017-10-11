defmodule EverlearnWeb.PackControllerTest do
  use EverlearnWeb.ConnCase

  alias Everlearn.Contents

  @create_attrs %{active: true, level: 42, title: "some title"}
  @update_attrs %{active: false, level: 43, title: "some updated title"}
  @invalid_attrs %{active: nil, level: nil, title: nil}

  def fixture(:pack) do
    {:ok, pack} = Contents.create_pack(@create_attrs)
    pack
  end

  describe "index" do
    test "lists all packs", %{conn: conn} do
      conn = get conn, pack_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Packs"
    end
  end

  describe "new pack" do
    test "renders form", %{conn: conn} do
      conn = get conn, pack_path(conn, :new)
      assert html_response(conn, 200) =~ "New Pack"
    end
  end

  describe "create pack" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, pack_path(conn, :create), pack: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == pack_path(conn, :show, id)

      conn = get conn, pack_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Pack"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, pack_path(conn, :create), pack: @invalid_attrs
      assert html_response(conn, 200) =~ "New Pack"
    end
  end

  describe "edit pack" do
    setup [:create_pack]

    test "renders form for editing chosen pack", %{conn: conn, pack: pack} do
      conn = get conn, pack_path(conn, :edit, pack)
      assert html_response(conn, 200) =~ "Edit Pack"
    end
  end

  describe "update pack" do
    setup [:create_pack]

    test "redirects when data is valid", %{conn: conn, pack: pack} do
      conn = put conn, pack_path(conn, :update, pack), pack: @update_attrs
      assert redirected_to(conn) == pack_path(conn, :show, pack)

      conn = get conn, pack_path(conn, :show, pack)
      assert html_response(conn, 200) =~ "some updated title"
    end

    test "renders errors when data is invalid", %{conn: conn, pack: pack} do
      conn = put conn, pack_path(conn, :update, pack), pack: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Pack"
    end
  end

  describe "delete pack" do
    setup [:create_pack]

    test "deletes chosen pack", %{conn: conn, pack: pack} do
      conn = delete conn, pack_path(conn, :delete, pack)
      assert redirected_to(conn) == pack_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, pack_path(conn, :show, pack)
      end
    end
  end

  defp create_pack(_) do
    pack = fixture(:pack)
    {:ok, pack: pack}
  end
end

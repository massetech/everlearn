defmodule EverlearnWeb.DataControllerTest do
  use EverlearnWeb.ConnCase

  alias Everlearn.Members
  alias Everlearn.Members.Data

  @create_attrs %{data: "some data"}
  @update_attrs %{data: "some updated data"}
  @invalid_attrs %{data: nil}

  def fixture(:data) do
    {:ok, data} = Members.create_data(@create_attrs)
    data
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all datas", %{conn: conn} do
      conn = get conn, data_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create data" do
    test "renders data when data is valid", %{conn: conn} do
      conn = post conn, data_path(conn, :create), data: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, data_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "data" => "some data"}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, data_path(conn, :create), data: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update data" do
    setup [:create_data]

    test "renders data when data is valid", %{conn: conn, data: %Data{id: id} = data} do
      conn = put conn, data_path(conn, :update, data), data: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, data_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "data" => "some updated data"}
    end

    test "renders errors when data is invalid", %{conn: conn, data: data} do
      conn = put conn, data_path(conn, :update, data), data: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete data" do
    setup [:create_data]

    test "deletes chosen data", %{conn: conn, data: data} do
      conn = delete conn, data_path(conn, :delete, data)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, data_path(conn, :show, data)
      end
    end
  end

  defp create_data(_) do
    data = fixture(:data)
    {:ok, data: data}
  end
end

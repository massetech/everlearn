defmodule Everlearn.Contents do
  @moduledoc """
  The Contents context.
  """

  import Ecto.Query, warn: false
  alias Everlearn.Repo

  alias Everlearn.Contents.Pack

  @doc """
  Returns the list of packs.

  ## Examples

      iex> list_packs()
      [%Pack{}, ...]

  """
  def list_packs do
    Repo.all(Pack)
  end

  @doc """
  Gets a single pack.

  Raises `Ecto.NoResultsError` if the Pack does not exist.

  ## Examples

      iex> get_pack!(123)
      %Pack{}

      iex> get_pack!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pack!(id), do: Repo.get!(Pack, id)

  @doc """
  Creates a pack.

  ## Examples

      iex> create_pack(%{field: value})
      {:ok, %Pack{}}

      iex> create_pack(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pack(attrs \\ %{}) do
    %Pack{}
    |> Pack.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pack.

  ## Examples

      iex> update_pack(pack, %{field: new_value})
      {:ok, %Pack{}}

      iex> update_pack(pack, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pack(%Pack{} = pack, attrs) do
    pack
    |> Pack.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Pack.

  ## Examples

      iex> delete_pack(pack)
      {:ok, %Pack{}}

      iex> delete_pack(pack)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pack(%Pack{} = pack) do
    Repo.delete(pack)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pack changes.

  ## Examples

      iex> change_pack(pack)
      %Ecto.Changeset{source: %Pack{}}

  """
  def change_pack(%Pack{} = pack) do
    Pack.changeset(pack, %{})
  end

  alias Everlearn.Contents.Classroom

  @doc """
  Returns the list of classrooms.

  ## Examples

      iex> list_classrooms()
      [%Classroom{}, ...]

  """
  def list_classrooms do
    Repo.all(Classroom)
  end

  @doc """
  Gets a single classroom.

  Raises `Ecto.NoResultsError` if the Classroom does not exist.

  ## Examples

      iex> get_classroom!(123)
      %Classroom{}

      iex> get_classroom!(456)
      ** (Ecto.NoResultsError)

  """
  def get_classroom!(id), do: Repo.get!(Classroom, id)

  @doc """
  Creates a classroom.

  ## Examples

      iex> create_classroom(%{field: value})
      {:ok, %Classroom{}}

      iex> create_classroom(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_classroom(attrs \\ %{}) do
    %Classroom{}
    |> Classroom.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a classroom.

  ## Examples

      iex> update_classroom(classroom, %{field: new_value})
      {:ok, %Classroom{}}

      iex> update_classroom(classroom, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_classroom(%Classroom{} = classroom, attrs) do
    classroom
    |> Classroom.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Classroom.

  ## Examples

      iex> delete_classroom(classroom)
      {:ok, %Classroom{}}

      iex> delete_classroom(classroom)
      {:error, %Ecto.Changeset{}}

  """
  def delete_classroom(%Classroom{} = classroom) do
    Repo.delete(classroom)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking classroom changes.

  ## Examples

      iex> change_classroom(classroom)
      %Ecto.Changeset{source: %Classroom{}}

  """
  def change_classroom(%Classroom{} = classroom) do
    Classroom.changeset(classroom, %{})
  end

  alias Everlearn.Contents.Item

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)

  @doc """
  Creates a item.

  ## Examples

      iex> create_item(%{field: value})
      {:ok, %Item{}}

      iex> create_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{source: %Item{}}

  """
  def change_item(%Item{} = item) do
    Item.changeset(item, %{})
  end

  alias Everlearn.Contents.PackItem

  @doc """
  Returns the list of packitems.

  ## Examples

      iex> list_packitems()
      [%PackItem{}, ...]

  """
  def list_packitems do
    Repo.all(PackItem)
  end

  @doc """
  Gets a single pack_item.

  Raises `Ecto.NoResultsError` if the Pack item does not exist.

  ## Examples

      iex> get_pack_item!(123)
      %PackItem{}

      iex> get_pack_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_pack_item!(id), do: Repo.get!(PackItem, id)

  @doc """
  Creates a pack_item.

  ## Examples

      iex> create_pack_item(%{field: value})
      {:ok, %PackItem{}}

      iex> create_pack_item(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_pack_item(attrs \\ %{}) do
    %PackItem{}
    |> PackItem.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a pack_item.

  ## Examples

      iex> update_pack_item(pack_item, %{field: new_value})
      {:ok, %PackItem{}}

      iex> update_pack_item(pack_item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_pack_item(%PackItem{} = pack_item, attrs) do
    pack_item
    |> PackItem.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a PackItem.

  ## Examples

      iex> delete_pack_item(pack_item)
      {:ok, %PackItem{}}

      iex> delete_pack_item(pack_item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_pack_item(%PackItem{} = pack_item) do
    Repo.delete(pack_item)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking pack_item changes.

  ## Examples

      iex> change_pack_item(pack_item)
      %Ecto.Changeset{source: %PackItem{}}

  """
  def change_pack_item(%PackItem{} = pack_item) do
    PackItem.changeset(pack_item, %{})
  end
end

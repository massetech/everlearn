defmodule Everlearn.Members do
  @moduledoc """
  The Members context.
  """

  import Ecto.Query, warn: false
  import Everlearn.{CustomMethods}
  require Logger
  require Poison

  alias Ueberauth.Auth
  alias Everlearn.Members.{Language, User, Membership, Memory}
  alias Everlearn.{Repo, QueryFilter, Contents}

  # -------------------------------- UEBERAUTH ----------------------------------------

  def signin(%Auth{} = auth) do
    insert_or_update_user(basic_info(auth))
  end

  defp basic_info(auth) do
    %{uid: auth.uid, token: token_from_auth(auth), token_expiration: exp_token_from_auth(auth), provider: Atom.to_string(auth.provider),
      name: name_from_auth(auth), avatar: avatar_from_auth(auth), email: email_from_auth(auth), nickname: nickname_from_auth(auth),
      language_id: 1, role: test_email(email_from_auth(auth))}
  end

  defp test_email(email) do
    if email == System.get_env("SUPER_EMAIL"), do: "SUPER", else: "MEMBER"
  end

  defp token_from_auth(%{credentials: %{token: token}}), do: token
  defp exp_token_from_auth(%{credentials: %{expires_at: exp}}) do
    # Google announces seconds
    Timex.shift(Timex.now, seconds: exp)
  end

  defp email_from_auth(%{info: %{email: email}}), do: email

  # github does it this way
  defp avatar_from_auth( %{info: %{urls: %{avatar_url: image}} }), do: image
  #facebook & google does it this way
  defp avatar_from_auth( %{info: %{image: image} }), do: image
  # default case if nothing matches
  defp avatar_from_auth( auth ) do
    Logger.warn auth.provider <> " needs to find an avatar URL!"
    Logger.debug(Poison.encode!(auth))
    nil
  end

  defp nickname_from_auth(auth) do
    if %{info: %{nickname: nickname}} = auth do
      case nickname do
        nil -> build_nickname(auth)
        _ -> nickname
      end
    else
      build_nickname(auth)
    end
  end
  defp build_nickname(auth) do
    if %{info: %{first_name: first_name}} = auth do
      first_name
    else
      name_from_auth(auth)
    end
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name = [auth.info.first_name, auth.info.last_name]
      |> Enum.filter(&(&1 != nil and &1 != ""))

      cond do
        length(name) == 0 -> auth.info.nickname
        true -> Enum.join(name, " ")
      end
    end
  end

  # -------------------------------- USER ----------------------------------------

  def list_users do
    Repo.all(User)
  end

  def admin_user? (user) do
    if Enum.member?(["ADMIN", "SUPER"], user.role) do
      true
    else
      false
    end
  end

  def super_user? (user) do
    if Enum.member?(["SUPER"], user.role) do
      true
    else
      false
    end
  end

  def get_user!(id), do: Repo.get!(User, id)

  defp insert_or_update_user(params) do
    case Repo.get_by(User, email: params.email) do
      nil ->
        IO.inspect(params)
        create_user(params)
      user ->
        #update_user(user, params)
        case update_user(user, params) do
          {:ok, user} -> {:updated, user}
          answer -> answer
        end
    end
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> IO.inspect()
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  # -------------------------------- MEMBERSHIPS ----------------------------------------

  def toogle_membership(user_id, pack_id) do
    case get_membership(user_id, pack_id) do
      %Membership{} = membership ->
        # There is allready a Membership : delete it (and delete the memories)
        case delete_membership(membership) do
          {:ok, membership} -> {:deleted, membership}
          {:error, reason} -> {:error, reason}
        end
      nil ->
        # There wasnt any Membership : create it
        case create_membership(%{user_id: user_id, pack_id: pack_id}) do
          {:ok, membership} ->
            case copy_items_to_memory(pack_id, membership.id) do
              {:ok, msg} -> {:ok, msg}
              {:error, msg} ->
                delete_membership(membership)
                {:error, msg}
            end
          {:error, reason} -> {:error, reason}
        end
    end
  end

  def list_memberships(params) do
    {result, rummage} = Membership
      |> Membership.rummage(QueryFilter.filter(params, Membership))
    memberships = result
      |> Repo.all()
      |> Repo.preload([:user, [pack: :language]])
    {memberships, rummage}
  end

  def get_membership!(id), do: Repo.get!(Membership, id)

  def get_membership(user_id, pack_id) do
    query = from m in Membership,
      where: m.pack_id == ^pack_id and m.user_id == ^user_id,
      select: m
    Repo.one(query)
  end

  def create_membership(attrs \\ %{}) do
    %Membership{}
    |> Membership.changeset(attrs)
    |> Repo.insert()
  end

  def update_membership(%Membership{} = membership, attrs) do
    membership
    |> Membership.changeset(attrs)
    |> Repo.update()
  end

  def delete_membership(%Membership{} = membership) do
    Repo.delete(membership)
  end

  def change_membership(%Membership{} = membership) do
    Membership.changeset(membership, %{})
  end

  # -------------------------------- MEMORYS ----------------------------------------
  alias Everlearn.Members.Memory

  def list_memorys do
    Repo.all(Memory)
  end

  def get_memory!(id), do: Repo.get!(Memory, id)

  def copy_items_to_memory(pack_id, membership_id) do
    memorys = Contents.get_items_from_pack(pack_id)
    # Keep a list of maps fith item_id concerned by the pack and membership_id
    |> Enum.reduce([], fn(item, acc) -> acc ++ [%{membership_id: membership_id, item_id: item.id, status: "new"}] end)
    # |> IO.inspect()
    # Enum on this list to save in the memory
    # |> Enum.each(fn(m) -> create_memory(m) end)
    |> Enum.reduce(%{ok: [], errors: []}, &insert_memory/2)
    # |> IO.inspect()
    case Enum.count(memorys.errors) do
      0 -> {:ok, "Everything ok for #{pack_id}"}
      _ -> {:error, "Errors on #{pack_id}"}
    end
  end

  def insert_memory(params, results) do
    case create_memory(params) do
      {:ok, membership} ->
        %{ok: results.ok ++ [{:ok, membership}], errors: results.errors}
      {:error, reason} ->
        %{ok: results.ok, errors: results.errors ++ [{:error, reason}]}
    end
  end

  def create_memory(attrs \\ %{}) do
    %Memory{}
    |> Memory.changeset(attrs)
    |> Repo.insert()
  end

  def update_memory(%Memory{} = memory, attrs) do
    memory
    |> Memory.changeset(attrs)
    |> Repo.update()
  end

  def delete_memory(%Memory{} = memory) do
    Repo.delete(memory)
  end

  def change_memory(%Memory{} = memory) do
    Memory.changeset(memory, %{})
  end

  # -------------------------------- LANGUAGE ----------------------------------------

  @doc """
  Returns a random language.

  ## Examples

      iex> list_languages()
      [%Language{}, ...]

  """

  def choose_random_language do
    Language
    |> Repo.all()
    |> Enum.random()
  end

  def language_select_btn do
    Repo.all(from(c in Language, select: {c.name, c.id}))
  end

  @doc """
  Returns the list of languages.

  ## Examples

      iex> list_languages()
      [%Language{}, ...]

  """
  def list_languages do
    Repo.all(Language)
  end

  @doc """
  Gets a single language.

  Raises `Ecto.NoResultsError` if the Language does not exist.

  ## Examples

      iex> get_language!(123)
      %Language{}

      iex> get_language!(456)
      ** (Ecto.NoResultsError)

  """
  def get_language!(id), do: Repo.get!(Language, id)

  @doc """
  Find a language by iso2code.

  """

  def get_language_by_code(iso2code) do
    Language
      # |> where([u], u.iso2code == ^iso2code)
      |> Repo.get_by(iso2code: String.downcase(iso2code))
      # |> Repo.get_by(iso2code: iso2code)
      # |> Repo.one
    # Language
    #   |> where([u], u.iso2code == iso2code)
    #   |> Repo.one
  end

  @doc """
  Creates a language.

  ## Examples

      iex> create_language(%{field: value})
      {:ok, %Language{}}

      iex> create_language(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_language(attrs \\ %{}) do
    %Language{}
    |> Language.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a language.

  ## Examples

      iex> update_language(language, %{field: new_value})
      {:ok, %Language{}}

      iex> update_language(language, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_language(%Language{} = language, attrs) do
    language
    |> Language.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Language.

  ## Examples

      iex> delete_language(language)
      {:ok, %Language{}}

      iex> delete_language(language)
      {:error, %Ecto.Changeset{}}

  """
  def delete_language(%Language{} = language) do
    Repo.delete(language)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking language changes.

  ## Examples

      iex> change_language(language)
      %Ecto.Changeset{source: %Language{}}

  """
  def change_language(%Language{} = language) do
    Language.changeset(language, %{})
  end
end

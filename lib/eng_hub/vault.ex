defmodule EngHub.Vault do
  @moduledoc """
  The Vault context.
  """

  import Ecto.Query, warn: false
  alias EngHub.Repo

  alias EngHub.Vault.File

  @doc """
  Returns the list of files.

  ## Examples

      iex> list_files()
      [%File{}, ...]

  """
  def list_files do
    Repo.all(File)
  end

  @doc """
  Gets a single file.

  Raises `Ecto.NoResultsError` if the File does not exist.

  ## Examples

      iex> get_file!(123)
      %File{}

      iex> get_file!(456)
      ** (Ecto.NoResultsError)

  """
  def get_file!(id), do: Repo.get!(File, id)

  @doc """
  Creates a file.

  ## Examples

      iex> create_file(%{field: value})
      {:ok, %File{}}

      iex> create_file(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_file(attrs) do
    %File{}
    |> File.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a file.

  ## Examples

      iex> update_file(file, %{field: new_value})
      {:ok, %File{}}

      iex> update_file(file, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_file(%File{} = file, attrs) do
    file
    |> File.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a file.

  ## Examples

      iex> delete_file(file)
      {:ok, %File{}}

      iex> delete_file(file)
      {:error, %Ecto.Changeset{}}

  """
  def delete_file(%File{} = file) do
    Repo.delete(file)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking file changes.

  ## Examples

      iex> change_file(file)
      %Ecto.Changeset{data: %File{}}

  """
  def change_file(%File{} = file, attrs \\ %{}) do
    File.changeset(file, attrs)
  end

  alias EngHub.Vault.FileVersion

  @doc """
  Returns the list of file_versions.

  ## Examples

      iex> list_file_versions()
      [%FileVersion{}, ...]

  """
  def list_file_versions do
    Repo.all(FileVersion)
  end

  @doc """
  Gets a single file_version.

  Raises `Ecto.NoResultsError` if the File version does not exist.

  ## Examples

      iex> get_file_version!(123)
      %FileVersion{}

      iex> get_file_version!(456)
      ** (Ecto.NoResultsError)

  """
  def get_file_version!(id), do: Repo.get!(FileVersion, id)

  @doc """
  Creates a file_version.

  ## Examples

      iex> create_file_version(%{field: value})
      {:ok, %FileVersion{}}

      iex> create_file_version(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_file_version(attrs) do
    %FileVersion{}
    |> FileVersion.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a file_version.

  ## Examples

      iex> update_file_version(file_version, %{field: new_value})
      {:ok, %FileVersion{}}

      iex> update_file_version(file_version, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_file_version(%FileVersion{} = file_version, attrs) do
    file_version
    |> FileVersion.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a file_version.

  ## Examples

      iex> delete_file_version(file_version)
      {:ok, %FileVersion{}}

      iex> delete_file_version(file_version)
      {:error, %Ecto.Changeset{}}

  """
  def delete_file_version(%FileVersion{} = file_version) do
    Repo.delete(file_version)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking file_version changes.

  ## Examples

      iex> change_file_version(file_version)
      %Ecto.Changeset{data: %FileVersion{}}

  """
  def change_file_version(%FileVersion{} = file_version, attrs \\ %{}) do
    FileVersion.changeset(file_version, attrs)
  end
end

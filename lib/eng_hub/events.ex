defmodule EngHub.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false
  alias EngHub.Repo

  alias EngHub.Events.Hackathon

  @doc """
  Returns the list of hackathons.

  ## Examples

      iex> list_hackathons()
      [%Hackathon{}, ...]

  """
  def list_hackathons do
    Repo.all(Hackathon)
  end

  @doc """
  Returns the list of hackathons (events) for a specific channel.
  """
  def list_events_by_channel(channel_id) do
    from(h in Hackathon, where: h.channel_id == ^channel_id, order_by: [desc: h.inserted_at])
    |> Repo.all()
  end

  @doc """
  Gets a single hackathon.

  Raises `Ecto.NoResultsError` if the Hackathon does not exist.

  ## Examples

      iex> get_hackathon!(123)
      %Hackathon{}

      iex> get_hackathon!(456)
      ** (Ecto.NoResultsError)

  """
  def get_hackathon!(id), do: Repo.get!(Hackathon, id)

  @doc """
  Creates a hackathon.

  ## Examples

      iex> create_hackathon(%{field: value})
      {:ok, %Hackathon{}}

      iex> create_hackathon(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_hackathon(attrs) do
    %Hackathon{}
    |> Hackathon.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a hackathon.

  ## Examples

      iex> update_hackathon(hackathon, %{field: new_value})
      {:ok, %Hackathon{}}

      iex> update_hackathon(hackathon, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_hackathon(%Hackathon{} = hackathon, attrs) do
    hackathon
    |> Hackathon.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a hackathon.

  ## Examples

      iex> delete_hackathon(hackathon)
      {:ok, %Hackathon{}}

      iex> delete_hackathon(hackathon)
      {:error, %Ecto.Changeset{}}

  """
  def delete_hackathon(%Hackathon{} = hackathon) do
    Repo.delete(hackathon)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking hackathon changes.

  ## Examples

      iex> change_hackathon(hackathon)
      %Ecto.Changeset{data: %Hackathon{}}

  """
  def change_hackathon(%Hackathon{} = hackathon, attrs \\ %{}) do
    Hackathon.changeset(hackathon, attrs)
  end
end

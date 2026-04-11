defmodule EngHub.Social do
  @moduledoc """
  The Social context.
  """

  import Ecto.Query, warn: false
  alias EngHub.Repo

  alias EngHub.Social.Follow

  @doc """
  Returns the list of follows.

  ## Examples

      iex> list_follows()
      [%Follow{}, ...]

  """
  def list_follows do
    Repo.all(Follow)
  end

  @doc """
  Gets a single follow.

  Raises `Ecto.NoResultsError` if the Follow does not exist.

  ## Examples

      iex> get_follow!(123)
      %Follow{}

      iex> get_follow!(456)
      ** (Ecto.NoResultsError)

  """
  def get_follow!(id), do: Repo.get!(Follow, id)

  @doc """
  Creates a follow.

  ## Examples

      iex> create_follow(%{field: value})
      {:ok, %Follow{}}

      iex> create_follow(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_follow(attrs) do
    %Follow{}
    |> Follow.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a follow.

  ## Examples

      iex> update_follow(follow, %{field: new_value})
      {:ok, %Follow{}}

      iex> update_follow(follow, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_follow(%Follow{} = follow, attrs) do
    follow
    |> Follow.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a follow.

  ## Examples

      iex> delete_follow(follow)
      {:ok, %Follow{}}

      iex> delete_follow(follow)
      {:error, %Ecto.Changeset{}}

  """
  def delete_follow(%Follow{} = follow) do
    Repo.delete(follow)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking follow changes.

  ## Examples

      iex> change_follow(follow)
      %Ecto.Changeset{data: %Follow{}}

  """
  def change_follow(%Follow{} = follow, attrs \\ %{}) do
    Follow.changeset(follow, attrs)
  end

  @doc """
  Follows a user.
  """
  def follow_user(follower_id, following_id) do
    result =
      %Follow{}
      |> Follow.changeset(%{follower_id: follower_id, following_id: following_id})
      |> Repo.insert()

    if match?({:ok, _}, result) do
      :telemetry.execute([:eng_hub, :social, :user_followed], %{count: 1})
    end

    result
  end

  @doc """
  Unfollows a user.
  """
  def unfollow_user(follower_id, following_id) do
    case Repo.get_by(Follow, follower_id: follower_id, following_id: following_id) do
      nil ->
        {:error, :not_found}

      follow ->
        result = Repo.delete(follow)

        if match?({:ok, _}, result) do
          :telemetry.execute([:eng_hub, :social, :user_unfollowed], %{count: 1})
        end

        result
    end
  end

  @doc """
  Checks if a user is following another user.
  """
  def following?(follower_id, following_id) do
    Repo.exists?(
      from f in Follow,
        where: f.follower_id == ^follower_id and f.following_id == ^following_id
    )
  end
end

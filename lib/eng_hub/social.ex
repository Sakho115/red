defmodule EngHub.Social do
  @moduledoc """
  The Social context.
  """

  import Ecto.Query, warn: false
  alias EngHub.Repo

  alias EngHub.Social.Follow
  alias EngHub.Social.Friendship
  alias EngHub.Identity.User

  @doc """
  Returns the list of follows.
  """
  def list_follows do
    Repo.all(Follow)
  end

  @doc """
  Follows a user.
  """
  def follow_user(follower_id, following_id) do
    create_follow(%{follower_id: follower_id, following_id: following_id})
  end

  def create_follow(attrs) do
    %Follow{}
    |> Follow.changeset(attrs)
    |> Repo.insert()
  end

  def get_follow!(id), do: Repo.get!(Follow, id)

  def update_follow(%Follow{} = follow, attrs) do
    follow
    |> Follow.changeset(attrs)
    |> Repo.update()
  end

  def delete_follow(%Follow{} = follow) do
    Repo.delete(follow)
  end

  def change_follow(%Follow{} = follow, attrs \\ %{}) do
    Follow.changeset(follow, attrs)
  end

  def create_friendship(attrs) do
    %Friendship{}
    |> Friendship.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Unfollows a user.
  """
  def unfollow_user(follower_id, following_id) do
    {count, _} =
      from(f in Follow, where: f.follower_id == ^follower_id and f.following_id == ^following_id)
      |> Repo.delete_all()

    if count > 0 do
      {:ok, :deleted}
    else
      {:error, :not_found}
    end
  end

  @doc """
  Checks if a user is following another user.
  """
  def following?(follower_id, following_id) do
    Repo.exists?(
      from(f in Follow, where: f.follower_id == ^follower_id and f.following_id == ^following_id)
    )
  end

  def list_friendships(user_id, status) do
    from(f in Friendship,
      where: f.user_id == ^user_id and f.status == ^status,
      preload: [:friend],
      order_by: [asc: f.inserted_at]
    )
    |> Repo.all()
  end

  def send_friend_request(user_id, target_username) do
    target_user = Repo.get_by(User, username: target_username)

    cond do
      is_nil(target_user) ->
        {:error, :user_not_found}

      target_user.id == user_id ->
        {:error, :cannot_friend_self}

      # Check for existing relationship
      Repo.exists?(
        from(f in Friendship, where: f.user_id == ^user_id and f.friend_id == ^target_user.id)
      ) ->
        {:error, :already_exists}

      true ->
        Repo.transaction(fn ->
          # Entry for User A (Sender)
          f1_changeset =
            %Friendship{}
            |> Friendship.changeset(%{
              user_id: user_id,
              friend_id: target_user.id,
              status: :pending_sent
            })

          # Entry for User B (Receiver)
          f2_changeset =
            %Friendship{}
            |> Friendship.changeset(%{
              user_id: target_user.id,
              friend_id: user_id,
              status: :pending_received
            })

          with {:ok, f1} <- Repo.insert(f1_changeset),
               {:ok, f2} <- Repo.insert(f2_changeset) do
            broadcast_friendship_change(f1, :request_sent)
            broadcast_friendship_change(f2, :request_received)
            f1
          else
            {:error, reason} -> Repo.rollback(reason)
          end
        end)
    end
  end

  def accept_friendship(user_id, friend_id) do
    Repo.transaction(fn ->
      # Update entry for User A (Receiver who is accepting)
      f1 =
        Repo.get_by(Friendship,
          user_id: user_id,
          friend_id: friend_id,
          status: :pending_received
        )

      # Update entry for User B (Sender who is being accepted)
      f2 = Repo.get_by(Friendship, user_id: friend_id, friend_id: user_id, status: :pending_sent)

      case {f1, f2} do
        {%Friendship{}, %Friendship{}} ->
          {:ok, f1} = f1 |> Friendship.changeset(%{status: :friends}) |> Repo.update()
          {:ok, f2} = f2 |> Friendship.changeset(%{status: :friends}) |> Repo.update()

          broadcast_friendship_change(f1, :request_accepted)
          broadcast_friendship_change(f2, :request_accepted)

          :ok

        _ ->
          Repo.rollback(:not_found)
      end
    end)
  end

  def remove_friendship(user_id, friend_id) do
    Repo.transaction(fn ->
      Repo.delete_all(
        from(f in Friendship, where: f.user_id == ^user_id and f.friend_id == ^friend_id)
      )

      Repo.delete_all(
        from(f in Friendship, where: f.user_id == ^friend_id and f.friend_id == ^user_id)
      )

      broadcast_friendship_change(%{user_id: user_id}, :removed)
      broadcast_friendship_change(%{user_id: friend_id}, :removed)
    end)
  end

  @doc """
  Returns a list of users who are friends with both user_a and user_b.
  """
  def get_mutual_friends(user_a_id, user_b_id) do
    query =
      from u in User,
        join: f1 in Friendship,
        on: f1.friend_id == u.id,
        join: f2 in Friendship,
        on: f2.friend_id == u.id,
        where: f1.user_id == ^user_a_id and f1.status == :friends,
        where: f2.user_id == ^user_b_id and f2.status == :friends,
        select: u

    Repo.all(query)
  end

  defp broadcast_friendship_change(friendship, event) do
    Phoenix.PubSub.broadcast(
      EngHub.PubSub,
      "friendships:#{friendship.user_id}",
      {__MODULE__, event, friendship}
    )
  end
end

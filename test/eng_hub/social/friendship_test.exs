defmodule EngHub.Social.FriendshipTest do
  use EngHub.DataCase
  alias EngHub.Social
  alias EngHub.Identity.User
  alias EngHub.Repo

  setup do
    user_a = %User{email: "a@example.com", username: "user_a"} |> Repo.insert!()
    user_b = %User{email: "b@example.com", username: "user_b"} |> Repo.insert!()
    {:ok, user_a: user_a, user_b: user_b}
  end

  test "friendship handshake flow", %{user_a: user_a, user_b: user_b} do
    # 1. Send Request
    assert {:ok, _} = Social.send_friend_request(user_a.id, user_b.username)

    # Check A's state
    [f_a] = Social.list_friendships(user_a.id, :pending_sent)
    assert f_a.friend_id == user_b.id

    # Check B's state
    [f_b] = Social.list_friendships(user_b.id, :pending_received)
    assert f_b.friend_id == user_a.id

    # 2. Accept Request
    assert {:ok, :ok} = Social.accept_friendship(user_b.id, user_a.id)

    # Check both are friends
    assert length(Social.list_friendships(user_a.id, :friends)) == 1
    assert length(Social.list_friendships(user_b.id, :friends)) == 1

    # Check no pending left
    assert Social.list_friendships(user_a.id, :pending_sent) == []
    assert Social.list_friendships(user_b.id, :pending_received) == []
  end

  test "removing friendship deletes both records", %{user_a: user_a, user_b: user_b} do
    Social.send_friend_request(user_a.id, user_b.username)
    Social.accept_friendship(user_b.id, user_a.id)

    assert {:ok, _} = Social.remove_friendship(user_a.id, user_b.id)

    assert Social.list_friendships(user_a.id, :friends) == []
    assert Social.list_friendships(user_b.id, :friends) == []
  end
end

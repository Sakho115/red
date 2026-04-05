defmodule EngHub.SocialTest do
  use EngHub.DataCase

  alias EngHub.Social

  describe "follows" do
    alias EngHub.Social.Follow

    import EngHub.SocialFixtures

    @invalid_attrs %{follower_id: nil, following_id: nil}

    test "list_follows/0 returns all follows" do
      follow = follow_fixture()
      assert Social.list_follows() == [follow]
    end

    test "get_follow!/1 returns the follow with given id" do
      follow = follow_fixture()
      assert Social.get_follow!(follow.id) == follow
    end

    test "create_follow/1 with valid data creates a follow" do
      follower = EngHub.IdentityFixtures.user_fixture()
      following = EngHub.IdentityFixtures.user_fixture()
      valid_attrs = %{follower_id: follower.id, following_id: following.id}

      assert {:ok, %Follow{} = follow} = Social.create_follow(valid_attrs)
      assert follow.follower_id == follower.id
      assert follow.following_id == following.id
    end

    test "create_follow/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Social.create_follow(@invalid_attrs)
    end

    test "update_follow/2 with valid data updates the follow" do
      follow = follow_fixture()
      update_attrs = %{}

      assert {:ok, %Follow{} = follow} = Social.update_follow(follow, update_attrs)
    end

    test "update_follow/2 with invalid data returns error changeset" do
      follow = follow_fixture()
      assert {:error, %Ecto.Changeset{}} = Social.update_follow(follow, @invalid_attrs)
      assert follow == Social.get_follow!(follow.id)
    end

    test "delete_follow/1 deletes the follow" do
      follow = follow_fixture()
      assert {:ok, %Follow{}} = Social.delete_follow(follow)
      assert_raise Ecto.NoResultsError, fn -> Social.get_follow!(follow.id) end
    end

    test "change_follow/1 returns a follow changeset" do
      follow = follow_fixture()
      assert %Ecto.Changeset{} = Social.change_follow(follow)
    end
    test "follow_user/2 creates a follow" do
      follower = EngHub.IdentityFixtures.user_fixture()
      following = EngHub.IdentityFixtures.user_fixture()
      
      assert {:ok, _} = Social.follow_user(follower.id, following.id)
      assert Social.following?(follower.id, following.id)
    end
    
    test "unfollow_user/2 deletes a follow" do
      follower = EngHub.IdentityFixtures.user_fixture()
      following = EngHub.IdentityFixtures.user_fixture()
      
      Social.follow_user(follower.id, following.id)
      assert {:ok, _} = Social.unfollow_user(follower.id, following.id)
      refute Social.following?(follower.id, following.id)
    end
  end
end

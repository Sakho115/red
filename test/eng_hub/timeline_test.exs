defmodule EngHub.TimelineTest do
  use EngHub.DataCase

  alias EngHub.Timeline

  describe "posts" do
    alias EngHub.Timeline.Post

    import EngHub.TimelineFixtures

    @invalid_attrs %{body: nil, code_snippet: nil, github_url: nil}

    test "list_posts/0 returns all posts" do
      post = post_fixture() |> EngHub.Repo.preload(:user)
      assert Timeline.list_posts() == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Timeline.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      user = EngHub.IdentityFixtures.user_fixture()
      valid_attrs = %{body: "some body", code_snippet: "some code_snippet", github_url: "some github_url", user_id: user.id}

      assert {:ok, %Post{} = post} = Timeline.create_post(valid_attrs)
      assert post.body == "some body"
      assert post.code_snippet == "some code_snippet"
      assert post.github_url == "some github_url"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Timeline.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{body: "some updated body", code_snippet: "some updated code_snippet", github_url: "some updated github_url"}

      assert {:ok, %Post{} = post} = Timeline.update_post(post, update_attrs)
      assert post.body == "some updated body"
      assert post.code_snippet == "some updated code_snippet"
      assert post.github_url == "some updated github_url"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Timeline.update_post(post, @invalid_attrs)
      assert post == Timeline.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Timeline.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Timeline.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Timeline.change_post(post)
    end
    test "list_feed_posts/1 returns own posts and followed users' posts" do
      user = EngHub.IdentityFixtures.user_fixture()
      other_user = EngHub.IdentityFixtures.user_fixture()
      followed_user = EngHub.IdentityFixtures.user_fixture()

      own_post = post_fixture(%{user_id: user.id})
      _other_post = post_fixture(%{user_id: other_user.id})
      followed_post = post_fixture(%{user_id: followed_user.id})

      EngHub.Social.follow_user(user.id, followed_user.id)

      feed_posts = Timeline.list_feed_posts(user.id)
      
      assert length(feed_posts) == 2
      # The posts can be returned in any order if inserted_at is same precision
      feed_post_ids = Enum.map(feed_posts, & &1.id) |> MapSet.new()
      assert feed_post_ids == MapSet.new([followed_post.id, own_post.id])
    end
  end
end

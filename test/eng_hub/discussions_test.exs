defmodule EngHub.DiscussionsTest do
  use EngHub.DataCase

  alias EngHub.Discussions

  describe "threads" do
    alias EngHub.Discussions.Thread

    import EngHub.DiscussionsFixtures

    @invalid_attrs %{title: nil, category: nil, content: nil}

    test "list_threads/0 returns all threads" do
      thread = thread_fixture()
      assert Discussions.list_threads() == [thread]
    end

    test "get_thread!/1 returns the thread with given id" do
      thread = thread_fixture()
      assert Discussions.get_thread!(thread.id) == thread
    end

    test "create_thread/1 with valid data creates a thread" do
      project = EngHub.ProjectsFixtures.project_fixture()
      user = EngHub.IdentityFixtures.user_fixture()

      valid_attrs = %{
        title: "some title",
        category: "some category",
        content: "some content",
        project_id: project.id,
        author_id: user.id
      }

      assert {:ok, %Thread{} = thread} = Discussions.create_thread(valid_attrs)
      assert thread.title == "some title"
      assert thread.category == "some category"
      assert thread.content == "some content"
    end

    test "create_thread/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Discussions.create_thread(@invalid_attrs)
    end

    test "update_thread/2 with valid data updates the thread" do
      thread = thread_fixture()

      update_attrs = %{
        title: "some updated title",
        category: "some updated category",
        content: "some updated content"
      }

      assert {:ok, %Thread{} = thread} = Discussions.update_thread(thread, update_attrs)
      assert thread.title == "some updated title"
      assert thread.category == "some updated category"
      assert thread.content == "some updated content"
    end

    test "update_thread/2 with invalid data returns error changeset" do
      thread = thread_fixture()
      assert {:error, %Ecto.Changeset{}} = Discussions.update_thread(thread, @invalid_attrs)
      assert thread == Discussions.get_thread!(thread.id)
    end

    test "delete_thread/1 deletes the thread" do
      thread = thread_fixture()
      assert {:ok, %Thread{}} = Discussions.delete_thread(thread)
      assert_raise Ecto.NoResultsError, fn -> Discussions.get_thread!(thread.id) end
    end

    test "change_thread/1 returns a thread changeset" do
      thread = thread_fixture()
      assert %Ecto.Changeset{} = Discussions.change_thread(thread)
    end
  end

  describe "comments" do
    alias EngHub.Discussions.Comment

    import EngHub.DiscussionsFixtures

    @invalid_attrs %{content: nil}

    test "list_comments/0 returns all comments" do
      comment = comment_fixture()
      assert Discussions.list_comments() == [comment]
    end

    test "get_comment!/1 returns the comment with given id" do
      comment = comment_fixture()
      assert Discussions.get_comment!(comment.id) == comment
    end

    test "create_comment/1 with valid data creates a comment" do
      valid_attrs = %{content: "some content"}

      assert {:ok, %Comment{} = comment} = Discussions.create_comment(valid_attrs)
      assert comment.content == "some content"
    end

    test "create_comment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Discussions.create_comment(@invalid_attrs)
    end

    test "update_comment/2 with valid data updates the comment" do
      comment = comment_fixture()
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Comment{} = comment} = Discussions.update_comment(comment, update_attrs)
      assert comment.content == "some updated content"
    end

    test "update_comment/2 with invalid data returns error changeset" do
      comment = comment_fixture()
      assert {:error, %Ecto.Changeset{}} = Discussions.update_comment(comment, @invalid_attrs)
      assert comment == Discussions.get_comment!(comment.id)
    end

    test "delete_comment/1 deletes the comment" do
      comment = comment_fixture()
      assert {:ok, %Comment{}} = Discussions.delete_comment(comment)
      assert_raise Ecto.NoResultsError, fn -> Discussions.get_comment!(comment.id) end
    end

    test "change_comment/1 returns a comment changeset" do
      comment = comment_fixture()
      assert %Ecto.Changeset{} = Discussions.change_comment(comment)
    end
  end
end

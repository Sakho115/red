defmodule EngHub.DiscussionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EngHub.Discussions` context.
  """

  @doc """
  Generate a thread.
  """
  def thread_fixture(attrs \\ %{}) do
    attrs = Map.new(attrs)
    project_id = Map.get(attrs, :project_id) || EngHub.ProjectsFixtures.project_fixture().id
    author_id = Map.get(attrs, :author_id) || EngHub.IdentityFixtures.user_fixture().id

    {:ok, thread} =
      attrs
      |> Enum.into(%{
        category: "some category",
        content: "some content",
        project_id: project_id,
        author_id: author_id,
        title: "some title"
      })
      |> EngHub.Discussions.create_thread()

    thread
  end

  @doc """
  Generate a comment.
  """
  def comment_fixture(attrs \\ %{}) do
    {:ok, comment} =
      attrs
      |> Enum.into(%{
        content: "some content"
      })
      |> EngHub.Discussions.create_comment()

    comment
  end
end

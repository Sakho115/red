defmodule EngHub.DiscussionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EngHub.Discussions` context.
  """

  @doc """
  Generate a thread.
  """
  def thread_fixture(attrs \\ %{}) do
    {:ok, thread} =
      attrs
      |> Enum.into(%{
        category: "some category",
        content: "some content",
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

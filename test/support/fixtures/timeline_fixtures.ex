defmodule EngHub.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EngHub.Timeline` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    user_id = Map.get(attrs, :user_id) || EngHub.IdentityFixtures.user_fixture().id

    {:ok, post} =
      attrs
      |> Enum.into(%{
        body: "some body",
        code_snippet: "some code_snippet",
        github_url: "some github_url",
        user_id: user_id
      })
      |> EngHub.Timeline.create_post()

    post
  end
end

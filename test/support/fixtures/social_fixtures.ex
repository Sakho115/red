defmodule EngHub.SocialFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EngHub.Social` context.
  """

  @doc """
  Generate a follow.
  """
  def follow_fixture(attrs \\ %{}) do
    follower_id = Map.get(attrs, :follower_id) || EngHub.IdentityFixtures.user_fixture().id
    following_id = Map.get(attrs, :following_id) || EngHub.IdentityFixtures.user_fixture().id

    {:ok, follow} =
      attrs
      |> Enum.into(%{
        follower_id: follower_id,
        following_id: following_id
      })
      |> EngHub.Social.create_follow()

    follow
  end
end

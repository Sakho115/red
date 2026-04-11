defmodule EngHub.MessagingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EngHub.Messaging` context.
  """

  @doc """
  Generate a channel.
  """
  def channel_fixture(attrs \\ %{}) do
    EngHub.CommunitiesFixtures.channel_fixture(attrs)
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    channel = channel_fixture()
    user = EngHub.IdentityFixtures.user_fixture()

    {:ok, message} =
      attrs
      |> Enum.into(%{
        content: "some content",
        channel_id: channel.id,
        user_id: user.id
      })
      |> EngHub.Messaging.create_message()

    message
  end
end

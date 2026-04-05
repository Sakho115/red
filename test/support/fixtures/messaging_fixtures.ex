defmodule EngHub.MessagingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EngHub.Messaging` context.
  """

  @doc """
  Generate a channel.
  """
  def channel_fixture(attrs \\ %{}) do
    {:ok, channel} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> EngHub.Messaging.create_channel()

    channel
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{
        content: "some content"
      })
      |> EngHub.Messaging.create_message()

    message
  end
end

defmodule EngHub.CommunitiesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EngHub.Communities` context.
  """

  @doc """
  Generate a server.
  """
  def server_fixture(attrs \\ %{}) do
    user = EngHub.IdentityFixtures.user_fixture()

    {:ok, server} =
      attrs
      |> Enum.into(%{
        name: "some server",
        owner_id: user.id
      })
      |> EngHub.Communities.create_server(user.id)

    server
  end

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    server = server_fixture()

    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: "some category",
        server_id: server.id
      })
      |> EngHub.Communities.create_category()

    category
  end

  @doc """
  Generate a channel.
  """
  def channel_fixture(attrs \\ %{}) do
    category = category_fixture()
    server = EngHub.Communities.get_server!(category.server_id)

    {:ok, channel} =
      attrs
      |> Enum.into(%{
        name: "some channel",
        type: :general_chat,
        server_id: server.id,
        category_id: category.id
      })
      |> EngHub.Communities.create_channel()

    channel
  end
end

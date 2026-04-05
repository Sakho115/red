defmodule EngHub.MarketplaceFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EngHub.Marketplace` context.
  """

  @doc """
  Generate a listing.
  """
  def listing_fixture(attrs \\ %{}) do
    {:ok, listing} =
      attrs
      |> Enum.into(%{
        description: "some description",
        price_or_exchange: "some price_or_exchange",
        status: "some status",
        title: "some title"
      })
      |> EngHub.Marketplace.create_listing()

    listing
  end
end

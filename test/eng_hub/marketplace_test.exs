defmodule EngHub.MarketplaceTest do
  use EngHub.DataCase

  alias EngHub.Marketplace

  describe "listings" do
    alias EngHub.Marketplace.Listing

    import EngHub.MarketplaceFixtures

    @invalid_attrs %{status: nil, description: nil, title: nil, price_or_exchange: nil}

    test "list_listings/0 returns all listings" do
      listing = listing_fixture()
      assert Marketplace.list_listings() == [listing]
    end

    test "get_listing!/1 returns the listing with given id" do
      listing = listing_fixture()
      assert Marketplace.get_listing!(listing.id) == listing
    end

    test "create_listing/1 with valid data creates a listing" do
      valid_attrs = %{status: "some status", description: "some description", title: "some title", price_or_exchange: "some price_or_exchange"}

      assert {:ok, %Listing{} = listing} = Marketplace.create_listing(valid_attrs)
      assert listing.status == "some status"
      assert listing.description == "some description"
      assert listing.title == "some title"
      assert listing.price_or_exchange == "some price_or_exchange"
    end

    test "create_listing/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Marketplace.create_listing(@invalid_attrs)
    end

    test "update_listing/2 with valid data updates the listing" do
      listing = listing_fixture()
      update_attrs = %{status: "some updated status", description: "some updated description", title: "some updated title", price_or_exchange: "some updated price_or_exchange"}

      assert {:ok, %Listing{} = listing} = Marketplace.update_listing(listing, update_attrs)
      assert listing.status == "some updated status"
      assert listing.description == "some updated description"
      assert listing.title == "some updated title"
      assert listing.price_or_exchange == "some updated price_or_exchange"
    end

    test "update_listing/2 with invalid data returns error changeset" do
      listing = listing_fixture()
      assert {:error, %Ecto.Changeset{}} = Marketplace.update_listing(listing, @invalid_attrs)
      assert listing == Marketplace.get_listing!(listing.id)
    end

    test "delete_listing/1 deletes the listing" do
      listing = listing_fixture()
      assert {:ok, %Listing{}} = Marketplace.delete_listing(listing)
      assert_raise Ecto.NoResultsError, fn -> Marketplace.get_listing!(listing.id) end
    end

    test "change_listing/1 returns a listing changeset" do
      listing = listing_fixture()
      assert %Ecto.Changeset{} = Marketplace.change_listing(listing)
    end
  end
end

defmodule EngHub.CommunitiesTest do
  use EngHub.DataCase

  alias EngHub.Communities
  alias EngHub.IdentityFixtures

  describe "servers" do
    test "create_server/2 creates a richer default structure" do
      user = IdentityFixtures.user_fixture()
      {:ok, server} = Communities.create_server(%{name: "Engineering Hub"}, user.id)

      # Reload server with tree
      {server, categories} = Communities.get_server_tree(server.id)

      assert server.name == "Engineering Hub"
      assert length(categories) == 3

      # Check Categories
      [cat1, cat2, cat3] = categories
      assert cat1.name == "General"
      assert cat1.emoji == "📢"
      assert cat2.name == "Engineering"
      assert cat2.emoji == "🛠️"
      assert cat3.name == "Resources"
      assert cat3.emoji == "📚"

      # Check Channels in General
      assert length(cat1.channels) == 2
      [ch1, ch2] = cat1.channels
      assert ch1.name == "announcements"
      assert ch1.topic == "Official updates and team announcements"
      assert ch2.name == "general"
      assert ch2.topic == "General team discussion and watercooler"

      # Check Channels in Engineering
      assert length(cat2.channels) == 2
      [ch3, ch4] = cat2.channels
      assert ch3.name == "projects"
      assert ch3.type == :project
      assert ch4.name == "technical-talk"
      assert ch4.type == :threads
    end
  end
end

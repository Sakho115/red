defmodule EngHub.MessagingTest do
  use EngHub.DataCase

  alias EngHub.Messaging

  describe "channels" do
    alias EngHub.Messaging.Channel

    import EngHub.MessagingFixtures

    @invalid_attrs %{name: nil}

    test "list_channels/0 returns all channels" do
      channel = channel_fixture()
      assert Messaging.list_channels() == [channel]
    end

    test "get_channel!/1 returns the channel with given id" do
      channel = channel_fixture()
      assert Messaging.get_channel!(channel.id) == channel
    end

    test "create_channel/1 with valid data creates a channel" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Channel{} = channel} = Messaging.create_channel(valid_attrs)
      assert channel.name == "some name"
    end

    test "create_channel/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_channel(@invalid_attrs)
    end

    test "update_channel/2 with valid data updates the channel" do
      channel = channel_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Channel{} = channel} = Messaging.update_channel(channel, update_attrs)
      assert channel.name == "some updated name"
    end

    test "update_channel/2 with invalid data returns error changeset" do
      channel = channel_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.update_channel(channel, @invalid_attrs)
      assert channel == Messaging.get_channel!(channel.id)
    end

    test "delete_channel/1 deletes the channel" do
      channel = channel_fixture()
      assert {:ok, %Channel{}} = Messaging.delete_channel(channel)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_channel!(channel.id) end
    end

    test "change_channel/1 returns a channel changeset" do
      channel = channel_fixture()
      assert %Ecto.Changeset{} = Messaging.change_channel(channel)
    end
  end

  describe "messages" do
    alias EngHub.Messaging.Message

    import EngHub.MessagingFixtures

    @invalid_attrs %{content: nil}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Messaging.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Messaging.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{content: "some content"}

      assert {:ok, %Message{} = message} = Messaging.create_message(valid_attrs)
      assert message.content == "some content"
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{content: "some updated content"}

      assert {:ok, %Message{} = message} = Messaging.update_message(message, update_attrs)
      assert message.content == "some updated content"
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.update_message(message, @invalid_attrs)
      assert message == Messaging.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Messaging.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Messaging.change_message(message)
    end
  end
end

defmodule EngHub.EventsTest do
  use EngHub.DataCase

  alias EngHub.Events

  describe "hackathons" do
    alias EngHub.Events.Hackathon

    import EngHub.EventsFixtures

    @invalid_attrs %{title: nil, start_date: nil, end_date: nil}

    test "list_hackathons/0 returns all hackathons" do
      hackathon = hackathon_fixture()
      assert Events.list_hackathons() == [hackathon]
    end

    test "get_hackathon!/1 returns the hackathon with given id" do
      hackathon = hackathon_fixture()
      assert Events.get_hackathon!(hackathon.id) == hackathon
    end

    test "create_hackathon/1 with valid data creates a hackathon" do
      valid_attrs = %{
        title: "some title",
        start_date: ~U[2026-03-15 16:07:00Z],
        end_date: ~U[2026-03-15 16:07:00Z]
      }

      assert {:ok, %Hackathon{} = hackathon} = Events.create_hackathon(valid_attrs)
      assert hackathon.title == "some title"
      assert hackathon.start_date == ~U[2026-03-15 16:07:00Z]
      assert hackathon.end_date == ~U[2026-03-15 16:07:00Z]
    end

    test "create_hackathon/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Events.create_hackathon(@invalid_attrs)
    end

    test "update_hackathon/2 with valid data updates the hackathon" do
      hackathon = hackathon_fixture()

      update_attrs = %{
        title: "some updated title",
        start_date: ~U[2026-03-16 16:07:00Z],
        end_date: ~U[2026-03-16 16:07:00Z]
      }

      assert {:ok, %Hackathon{} = hackathon} = Events.update_hackathon(hackathon, update_attrs)
      assert hackathon.title == "some updated title"
      assert hackathon.start_date == ~U[2026-03-16 16:07:00Z]
      assert hackathon.end_date == ~U[2026-03-16 16:07:00Z]
    end

    test "update_hackathon/2 with invalid data returns error changeset" do
      hackathon = hackathon_fixture()
      assert {:error, %Ecto.Changeset{}} = Events.update_hackathon(hackathon, @invalid_attrs)
      assert hackathon == Events.get_hackathon!(hackathon.id)
    end

    test "delete_hackathon/1 deletes the hackathon" do
      hackathon = hackathon_fixture()
      assert {:ok, %Hackathon{}} = Events.delete_hackathon(hackathon)
      assert_raise Ecto.NoResultsError, fn -> Events.get_hackathon!(hackathon.id) end
    end

    test "change_hackathon/1 returns a hackathon changeset" do
      hackathon = hackathon_fixture()
      assert %Ecto.Changeset{} = Events.change_hackathon(hackathon)
    end
  end
end

defmodule EngHub.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EngHub.Events` context.
  """

  @doc """
  Generate a hackathon.
  """
  def hackathon_fixture(attrs \\ %{}) do
    {:ok, hackathon} =
      attrs
      |> Enum.into(%{
        end_date: ~U[2026-03-15 16:07:00Z],
        start_date: ~U[2026-03-15 16:07:00Z],
        title: "some title"
      })
      |> EngHub.Events.create_hackathon()

    hackathon
  end
end

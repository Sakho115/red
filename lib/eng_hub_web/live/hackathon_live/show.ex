defmodule EngHubWeb.HackathonLive.Show do
  use EngHubWeb, :live_view

  alias EngHub.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Hackathon {@hackathon.id}
        <:subtitle>This is a hackathon record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/hackathons"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/hackathons/#{@hackathon}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit hackathon
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@hackathon.title}</:item>
        <:item title="Start date">{@hackathon.start_date}</:item>
        <:item title="End date">{@hackathon.end_date}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Hackathon")
     |> assign(:hackathon, Events.get_hackathon!(id))}
  end
end

defmodule EngHubWeb.HackathonLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Events

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Hackathons
        <:actions>
          <.button variant="primary" navigate={~p"/hackathons/new"}>
            <.icon name="hero-plus" /> New Hackathon
          </.button>
        </:actions>
      </.header>

      <.table
        id="hackathons"
        rows={@streams.hackathons}
        row_click={fn {_id, hackathon} -> JS.navigate(~p"/hackathons/#{hackathon}") end}
      >
        <:col :let={{_id, hackathon}} label="Title">{hackathon.title}</:col>
        <:col :let={{_id, hackathon}} label="Start date">{hackathon.start_date}</:col>
        <:col :let={{_id, hackathon}} label="End date">{hackathon.end_date}</:col>
        <:action :let={{_id, hackathon}}>
          <div class="sr-only">
            <.link navigate={~p"/hackathons/#{hackathon}"}>Show</.link>
          </div>
          <.link navigate={~p"/hackathons/#{hackathon}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, hackathon}}>
          <.link
            phx-click={JS.push("delete", value: %{id: hackathon.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Hackathons")
     |> stream(:hackathons, list_hackathons())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    hackathon = Events.get_hackathon!(id)
    {:ok, _} = Events.delete_hackathon(hackathon)

    {:noreply, stream_delete(socket, :hackathons, hackathon)}
  end

  defp list_hackathons() do
    Events.list_hackathons()
  end
end

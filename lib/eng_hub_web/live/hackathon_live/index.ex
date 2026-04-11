defmodule EngHubWeb.HackathonLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Events
  alias EngHub.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="p-8 max-w-7xl mx-auto">
        <header class="flex items-center justify-between mb-8">
          <div>
            <h1 class="text-4xl font-black text-white italic tracking-tighter uppercase">Hackathons & Events</h1>
            <p class="text-white/40 font-medium">Join engineering competitions and showcase your builds.</p>
          </div>
          <.button variant="primary" navigate={~p"/hackathons/new"} class="shadow-xl shadow-primary/20">
            <.icon name="hero-plus" /> New Event
          </.button>
        </header>

        <div class="bg-white/5 border border-white/5 backdrop-blur-xl rounded-[32px] overflow-hidden">
          <.table
            id="hackathons"
            rows={@streams.hackathons}
            row_click={fn {_id, hackathon} -> JS.navigate(~p"/hackathons/#{hackathon}") end}
          >
            <:col :let={{_id, hackathon}} label="Competition" class="font-bold text-white italic">
              <.icon name="hero-trophy" class="w-4 h-4 mr-2 text-warning opacity-50" />
              {hackathon.title}
            </:col>
            <:col :let={{_id, hackathon}} label="Timeline" class="text-white/40 font-medium">
              <span class="text-primary">{Calendar.strftime(hackathon.start_date, "%b %d")}</span>
              <span class="mx-2 text-white/10">—</span>
              <span class="text-secondary">{Calendar.strftime(hackathon.end_date, "%b %d, %Y")}</span>
            </:col>
            <:action :let={{_id, hackathon}}>
              <div class="sr-only">
                <.link navigate={~p"/hackathons/#{hackathon}"}>Show</.link>
              </div>
              <.link
                :if={!hackathon.project_id || Projects.can?(hackathon.project_id, @current_user.id, "editor")}
                navigate={~p"/hackathons/#{hackathon}/edit"}
                class="text-primary hover:underline font-bold"
              >
                Edit
              </.link>
            </:action>
            <:action :let={{id, hackathon}}>
              <.link
                :if={!hackathon.project_id || Projects.can?(hackathon.project_id, @current_user.id, "editor")}
                phx-click={JS.push("delete", value: %{id: hackathon.id}) |> hide("##{id}")}
                data-confirm="Are you sure?"
                class="text-error/60 hover:text-error transition-colors"
              >
                Delete
              </.link>
            </:action>
          </.table>
        </div>
      </div>
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

    if !hackathon.project_id ||
         Projects.can?(hackathon.project_id, socket.assigns.current_user.id, "editor") do
      {:ok, _} = Events.delete_hackathon(hackathon)
      {:noreply, stream_delete(socket, :hackathons, hackathon)}
    else
      {:noreply,
       put_flash(socket, :error, "You do not have permission to delete this hackathon.")}
    end
  end

  defp list_hackathons() do
    Events.list_hackathons()
  end
end

defmodule EngHubWeb.ListingLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Marketplace
  alias EngHub.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="p-8 max-w-7xl mx-auto">
        <header class="flex items-center justify-between mb-8">
          <div>
            <h1 class="text-4xl font-black text-white italic tracking-tighter uppercase">Component Marketplace</h1>
            <p class="text-white/40 font-medium">Acquire and exchange engineering parts and components.</p>
          </div>
          <.button variant="primary" navigate={~p"/listings/new"} class="shadow-xl shadow-primary/20">
            <.icon name="hero-plus" /> New Listing
          </.button>
        </header>

        <div class="bg-white/5 border border-white/5 backdrop-blur-xl rounded-[32px] overflow-hidden">
          <.table
            id="listings"
            rows={@streams.listings}
            row_click={fn {_id, listing} -> JS.navigate(~p"/listings/#{listing}") end}
          >
            <:col :let={{_id, listing}} label="Item" class="font-bold text-white italic">{listing.title}</:col>
            <:col :let={{_id, listing}} label="Description" class="text-white/40 truncate max-w-md">{listing.description}</:col>
            <:col :let={{_id, listing}} label="Price/Exchange" class="text-primary font-black uppercase text-xs tracking-widest">{listing.price_or_exchange}</:col>
            <:col :let={{_id, listing}} label="Status" class="font-bold">
              <span class={[
                "px-2 py-0.5 rounded-md text-[10px] uppercase tracking-widest",
                listing.status == "available" && "bg-success/20 text-success",
                listing.status == "exchanged" && "bg-white/10 text-white/40",
                listing.status == "pending" && "bg-warning/20 text-warning"
              ]}>{listing.status}</span>
            </:col>
            <:action :let={{_id, listing}}>
              <div class="sr-only">
                <.link navigate={~p"/listings/#{listing}"}>Show</.link>
              </div>
              <.link
                :if={!listing.project_id || Projects.can?(listing.project_id, @current_user.id, "editor")}
                navigate={~p"/listings/#{listing}/edit"}
                class="text-primary hover:underline font-bold"
              >
                Edit
              </.link>
            </:action>
            <:action :let={{id, listing}}>
              <.link
                :if={!listing.project_id || Projects.can?(listing.project_id, @current_user.id, "editor")}
                phx-click={JS.push("delete", value: %{id: listing.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Listings")
     |> stream(:listings, list_listings())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    listing = Marketplace.get_listing!(id)

    if !listing.project_id ||
         Projects.can?(listing.project_id, socket.assigns.current_user.id, "editor") do
      {:ok, _} = Marketplace.delete_listing(listing)
      {:noreply, stream_delete(socket, :listings, listing)}
    else
      {:noreply, put_flash(socket, :error, "You do not have permission to delete this listing.")}
    end
  end

  defp list_listings() do
    Marketplace.list_listings()
  end
end

defmodule EngHubWeb.ListingLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Marketplace

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Listings
        <:actions>
          <.button variant="primary" navigate={~p"/listings/new"}>
            <.icon name="hero-plus" /> New Listing
          </.button>
        </:actions>
      </.header>

      <.table
        id="listings"
        rows={@streams.listings}
        row_click={fn {_id, listing} -> JS.navigate(~p"/listings/#{listing}") end}
      >
        <:col :let={{_id, listing}} label="Title">{listing.title}</:col>
        <:col :let={{_id, listing}} label="Description">{listing.description}</:col>
        <:col :let={{_id, listing}} label="Price or exchange">{listing.price_or_exchange}</:col>
        <:col :let={{_id, listing}} label="Status">{listing.status}</:col>
        <:action :let={{_id, listing}}>
          <div class="sr-only">
            <.link navigate={~p"/listings/#{listing}"}>Show</.link>
          </div>
          <.link navigate={~p"/listings/#{listing}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, listing}}>
          <.link
            phx-click={JS.push("delete", value: %{id: listing.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Listings")
     |> stream(:listings, list_listings())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    listing = Marketplace.get_listing!(id)
    {:ok, _} = Marketplace.delete_listing(listing)

    {:noreply, stream_delete(socket, :listings, listing)}
  end

  defp list_listings() do
    Marketplace.list_listings()
  end
end

defmodule EngHubWeb.ListingLive.Show do
  use EngHubWeb, :live_view

  alias EngHub.Marketplace

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing {@listing.id}
        <:subtitle>This is a listing record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/listings"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/listings/#{@listing}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit listing
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Title">{@listing.title}</:item>
        <:item title="Description">{@listing.description}</:item>
        <:item title="Price or exchange">{@listing.price_or_exchange}</:item>
        <:item title="Status">{@listing.status}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Listing")
     |> assign(:listing, Marketplace.get_listing!(id))}
  end
end

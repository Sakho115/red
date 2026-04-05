defmodule EngHubWeb.ListingLive.Form do
  use EngHubWeb, :live_view

  alias EngHub.Marketplace
  alias EngHub.Marketplace.Listing

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage listing records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="listing-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:description]} type="textarea" label="Description" />
        <.input field={@form[:price_or_exchange]} type="text" label="Price or exchange" />
        <.input field={@form[:status]} type="text" label="Status" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Listing</.button>
          <.button navigate={return_path(@return_to, @listing)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    listing = Marketplace.get_listing!(id)

    socket
    |> assign(:page_title, "Edit Listing")
    |> assign(:listing, listing)
    |> assign(:form, to_form(Marketplace.change_listing(listing)))
  end

  defp apply_action(socket, :new, _params) do
    listing = %Listing{}

    socket
    |> assign(:page_title, "New Listing")
    |> assign(:listing, listing)
    |> assign(:form, to_form(Marketplace.change_listing(listing)))
  end

  @impl true
  def handle_event("validate", %{"listing" => listing_params}, socket) do
    changeset = Marketplace.change_listing(socket.assigns.listing, listing_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"listing" => listing_params}, socket) do
    save_listing(socket, socket.assigns.live_action, listing_params)
  end

  defp save_listing(socket, :edit, listing_params) do
    case Marketplace.update_listing(socket.assigns.listing, listing_params) do
      {:ok, listing} ->
        {:noreply,
         socket
         |> put_flash(:info, "Listing updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, listing))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_listing(socket, :new, listing_params) do
    case Marketplace.create_listing(listing_params) do
      {:ok, listing} ->
        {:noreply,
         socket
         |> put_flash(:info, "Listing created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, listing))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _listing), do: ~p"/listings"
  defp return_path("show", listing), do: ~p"/listings/#{listing}"
end

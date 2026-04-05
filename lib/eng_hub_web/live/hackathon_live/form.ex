defmodule EngHubWeb.HackathonLive.Form do
  use EngHubWeb, :live_view

  alias EngHub.Events
  alias EngHub.Events.Hackathon

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage hackathon records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="hackathon-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:title]} type="text" label="Title" />
        <.input field={@form[:start_date]} type="datetime-local" label="Start date" />
        <.input field={@form[:end_date]} type="datetime-local" label="End date" />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Hackathon</.button>
          <.button navigate={return_path(@return_to, @hackathon)}>Cancel</.button>
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
    hackathon = Events.get_hackathon!(id)

    socket
    |> assign(:page_title, "Edit Hackathon")
    |> assign(:hackathon, hackathon)
    |> assign(:form, to_form(Events.change_hackathon(hackathon)))
  end

  defp apply_action(socket, :new, _params) do
    hackathon = %Hackathon{}

    socket
    |> assign(:page_title, "New Hackathon")
    |> assign(:hackathon, hackathon)
    |> assign(:form, to_form(Events.change_hackathon(hackathon)))
  end

  @impl true
  def handle_event("validate", %{"hackathon" => hackathon_params}, socket) do
    changeset = Events.change_hackathon(socket.assigns.hackathon, hackathon_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"hackathon" => hackathon_params}, socket) do
    save_hackathon(socket, socket.assigns.live_action, hackathon_params)
  end

  defp save_hackathon(socket, :edit, hackathon_params) do
    case Events.update_hackathon(socket.assigns.hackathon, hackathon_params) do
      {:ok, hackathon} ->
        {:noreply,
         socket
         |> put_flash(:info, "Hackathon updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, hackathon))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_hackathon(socket, :new, hackathon_params) do
    case Events.create_hackathon(hackathon_params) do
      {:ok, hackathon} ->
        {:noreply,
         socket
         |> put_flash(:info, "Hackathon created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, hackathon))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _hackathon), do: ~p"/hackathons"
  defp return_path("show", hackathon), do: ~p"/hackathons/#{hackathon}"
end

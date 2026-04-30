defmodule EngHubWeb.HomeLive.Index do
  use EngHubWeb, :live_view
  import EngHubWeb.PlaceholderComponents

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:active_tab, :friends)
     |> assign(:page_title, "Friends")}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params), do: assign(socket, :active_tab, :friends)
  defp apply_action(socket, :online, _params), do: assign(socket, :active_tab, :online)
  defp apply_action(socket, :all, _params), do: assign(socket, :active_tab, :all)
  defp apply_action(socket, :pending, _params), do: assign(socket, :active_tab, :pending)
  defp apply_action(socket, :blocked, _params), do: assign(socket, :active_tab, :blocked)
  defp apply_action(socket, :add_friend, _params), do: assign(socket, :active_tab, :add_friend)

  @impl true
  def render(assigns) do
    ~H"""
    <.list_placeholder title={"Friends - #{Atom.to_string(@active_tab) |> String.capitalize()}"} type="friends" />
    """
  end
end

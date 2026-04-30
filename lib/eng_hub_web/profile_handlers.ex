defmodule EngHubWeb.ProfileHandlers do
  @moduledoc """
  Common handlers for user profile UI events like mute and deafen.
  """
  import Phoenix.Component
  import Phoenix.LiveView

  def on_mount(:default, _params, _session, socket) do
    {:cont,
     socket
     |> attach_hook(:profile_events, :handle_event, fn
       "toggle_mute", params, socket -> handle_profile_event("toggle_mute", params, socket)
       "toggle_deafen", params, socket -> handle_profile_event("toggle_deafen", params, socket)
       _event, _params, socket -> {:cont, socket}
     end)}
  end

  defp handle_profile_event("toggle_mute", _params, socket) do
    {:halt, assign(socket, muted: !socket.assigns.muted)}
  end

  defp handle_profile_event("toggle_deafen", _params, socket) do
    new_deafened = !socket.assigns.deafened
    # Discord usually mutes you if you deafen yourself
    new_muted = if new_deafened, do: true, else: socket.assigns.muted
    {:halt, assign(socket, deafened: new_deafened, muted: new_muted)}
  end
end

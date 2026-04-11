defmodule EngHubWeb.CollaborationChannel do
  use EngHubWeb, :channel
  alias EngHubWeb.Presence

  @impl true
  def join("collaboration:" <> project_id, payload, socket) do
    if authorized?(payload, project_id, socket) do
      send(self(), :after_join)
      {:ok, assign(socket, :project_id, project_id)}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.current_user.id, %{
        online_at: inspect(System.system_time(:second)),
        email: socket.assigns.current_user.email
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end

  @impl true
  def handle_in("new_edit", payload, socket) do
    broadcast!(socket, "new_edit", payload)
    {:reply, :ok, socket}
  end

  defp authorized?(_payload, project_id, socket) do
    user = socket.assigns.current_user
    EngHub.Projects.can?(project_id, user.id, "viewer")
  end
end

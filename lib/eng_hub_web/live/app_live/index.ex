defmodule EngHubWeb.AppLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Communities

  import EngHubWeb.AppComponents

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    # Initial state setup
    # Note: the full servers list is needed for the sidebar globally
    servers = Communities.list_user_servers(user.id)

    socket =
      socket
      |> assign(:servers, servers)
      |> assign(:active_server_id, nil)
      |> assign(:active_channel_id, nil)
      |> assign(:active_dm_id, nil)
      |> assign(:current_view_type, :home)
      |> assign(:active_server, nil)
      |> assign(:active_channel, nil)
      |> assign(:categories, [])
      |> assign(:members, [])
      |> assign(:show_members?, true)
      |> assign(:open_panel, nil)
      |> assign(:active_modal, nil)
      |> assign(:settings_tab, nil)
      |> assign(:nested_action, nil)
      |> assign(:nested_params, %{})

    {:ok, socket, layout: false}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    socket =
      socket
      |> handle_route_params(socket.assigns.live_action, params)
      |> handle_query_params(params)

    {:noreply, socket}
  end

  defp handle_route_params(socket, :home, _params) do
    socket
    |> assign(:active_server_id, nil)
    |> assign(:active_channel_id, nil)
    |> assign(:current_view_type, :home)
    |> load_dms()
  end

  defp handle_route_params(socket, view_type, params) when view_type in [:threads, :threads_new, :threads_show, :threads_edit] do
    socket
    |> assign(:active_server_id, nil)
    |> assign(:active_channel_id, nil)
    |> assign(:current_view_type, :threads)
    |> assign(:nested_action, view_type)
    |> assign(:nested_params, params)
    |> load_threads()
  end

  defp handle_route_params(socket, view_type, params) when view_type in [:projects, :projects_new, :projects_show, :projects_edit] do
    socket
    |> assign(:active_server_id, nil)
    |> assign(:active_channel_id, nil)
    |> assign(:current_view_type, :projects)
    |> assign(:nested_action, view_type)
    |> assign(:nested_params, params)
    |> load_projects()
  end

  defp handle_route_params(socket, :dms, _params) do
    socket
    |> assign(:active_server_id, nil)
    |> assign(:active_channel_id, nil)
    |> assign(:current_view_type, :dms_home)
    |> load_dms()
  end

  defp handle_route_params(socket, :dm, %{"id" => dm_id}) do
    socket
    |> assign(:active_server_id, nil)
    |> assign(:active_channel_id, nil)
    |> assign(:active_dm_id, dm_id)
    |> assign(:current_view_type, :chat)
    |> load_dms()
    |> setup_dm_context(dm_id)
  end

  defp handle_route_params(socket, :server, %{"server_id" => server_id}) do
    socket
    |> assign(:active_server_id, server_id)
    |> load_server_context(server_id)
    |> assign(:current_view_type, :server_home)
  end

  defp handle_route_params(socket, :channel, %{"server_id" => server_id, "channel_id" => channel_id}) do
    socket
    |> assign(:active_server_id, server_id)
    |> assign(:active_channel_id, channel_id)
    |> load_server_context(server_id)
    |> load_channel_context(channel_id)
  end

  defp handle_query_params(socket, params) do
    socket
    |> assign(:open_panel, parse_panel(params["panel"], params))
    |> assign(:settings_tab, params["settings"])
  end

  defp parse_panel(nil, _), do: nil
  defp parse_panel("profile", params), do: %{type: :user_profile, id: params["user_id"]}
  defp parse_panel("search", _), do: %{type: :search}
  defp parse_panel("thread", params), do: %{type: :thread, id: params["thread_id"]}
  defp parse_panel(_, _), do: nil

  # --- Context Loaders ---
  
  defp load_dms(socket) do
    user_id = socket.assigns.current_user.id
    dms = EngHub.Communities.list_dm_channels(user_id)
    assign(socket, :dms, dms)
  end

  defp load_threads(socket) do
    # Later we will fetch threads from DB, for now empty list or load from context
    assign(socket, :threads, [])
  end

  defp load_projects(socket) do
    # Later fetch projects
    assign(socket, :projects, [])
  end

  defp setup_dm_context(socket, _dm_id) do
    # Here we would load the specific DM contents
    assign(socket, current_view_type: :chat)
  end

  defp load_server_context(socket, server_id) do
    # Only reload if it changed
    current_server = socket.assigns.active_server
    if current_server && to_string(current_server.id) == server_id do
      socket
    else
      {server, categories} = Communities.get_server_tree(server_id)
      members = Communities.list_server_members(server.id)
      
      socket
      |> assign(:active_server, server)
      |> assign(:categories, categories)
      |> assign(:members, members)
    end
  rescue
    _ -> push_navigate(socket, to: ~p"/")
  end

  defp load_channel_context(socket, channel_id) do
    categories = socket.assigns.categories || []
    all_channels = Enum.flat_map(categories, & &1.channels)
    active_channel = Enum.find(all_channels, &(to_string(&1.id) == channel_id))
    
    if active_channel do
      socket
      |> assign(:active_channel, active_channel)
      |> assign(:current_view_type, active_channel.type || :chat)
    else
      # Fallback to general chat if not found
      assign(socket, :current_view_type, :chat)
    end
  end

  # Additional basic event handlers for modal/panels
  @impl true
  def handle_event("open_modal", %{"modal" => modal_type}, socket) do
    {:noreply, assign(socket, active_modal: String.to_existing_atom(modal_type))}
  end

  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, active_modal: nil)}
  end

  def handle_event("close_panel", _, socket) do
    # Remove panel from URL params via patch
    params = %{} |> Map.put("settings", socket.assigns.settings_tab)
    
    path = current_path(socket, params)
    {:noreply, push_patch(socket, to: path)}
  end

  def handle_event("close_settings", _, socket) do
    params = %{} |> Map.put("panel", (socket.assigns.open_panel && socket.assigns.open_panel.type))
    
    path = current_path(socket, params)
    {:noreply, push_patch(socket, to: path)}
  end

  def handle_event("open_chat", %{"type" => type, "id" => id}, socket) do
    {:noreply, 
      socket
      |> assign(:chat_context_open?, true)
      |> assign(:chat_context_type, type)
      |> assign(:chat_context_id, id)}
  end

  def handle_event("close_chat", _, socket) do
    {:noreply, assign(socket, :chat_context_open?, false)}
  end

  defp current_path(socket, params) do
    # Generate the base path based on current state
    base =
      cond do
        socket.assigns.active_channel_id ->
          ~p"/s/#{socket.assigns.active_server_id}/c/#{socket.assigns.active_channel_id}"
        socket.assigns.active_server_id ->
          ~p"/s/#{socket.assigns.active_server_id}"
        socket.assigns.active_dm_id ->
          ~p"/dms/#{socket.assigns.active_dm_id}"
        true ->
          ~p"/"
      end
    
    # filter out nils
    query = params |> Enum.reject(fn {_, v} -> is_nil(v) end) |> URI.encode_query()
    
    if query == "", do: base, else: "#{base}?#{query}"
  end
end

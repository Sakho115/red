defmodule EngHubWeb.ChannelLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Messaging
  alias EngHub.Projects

  @impl true
  def mount(%{"project_id" => project_id} = params, _session, socket) do
    project = Projects.get_project!(project_id)
    
    # Simple list filter for now
    channels = Messaging.list_channels() |> Enum.filter(&(&1.project_id == String.to_integer(project_id)))
    
    active_channel_id = params["id"] || (if length(channels) > 0, do: to_string(hd(channels).id), else: nil)
    
    messages = 
      if active_channel_id do
        if connected?(socket), do: Messaging.subscribe(active_channel_id)
        Messaging.list_messages_by_channel(active_channel_id)
      else
        []
      end

    {:ok,
     socket
     |> assign(:project, project)
     |> assign(:channels, channels)
     |> assign(:active_channel_id, active_channel_id)
     |> stream(:messages, messages)
     |> assign(:form, to_form(%{"content" => ""}))}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex h-[80vh] border rounded-lg overflow-hidden bg-white shadow-sm">
      <!-- Sidebar -->
      <div class="w-64 bg-gray-50 border-r flex flex-col">
        <div class="p-4 border-b bg-gray-100 font-bold flex justify-between items-center text-gray-800">
          {@project.name}
        </div>
        <div class="p-4 flex-1 overflow-y-auto">
          <h3 class="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-3">Text Channels</h3>
          <ul class="space-y-1">
            <li :for={channel <- @channels}>
              <.link 
                navigate={~p"/projects/#{@project.id}/channels/#{channel.id}"}
                class={["flex items-center px-2 py-1.5 rounded-md text-sm cursor-pointer",
                        to_string(channel.id) == @active_channel_id && "bg-gray-200 text-gray-900 font-medium" || "text-gray-600 hover:bg-gray-200"]}
              >
                <Heroicons.hashtag class="h-4 w-4 mr-2 opacity-60" />
                {channel.name}
              </.link>
            </li>
          </ul>
        </div>
      </div>

      <!-- Main Chat Area -->
      <div class="flex-1 flex flex-col bg-white">
        <div :if={!@active_channel_id} class="flex-1 flex items-center justify-center text-gray-500">
          No channels selected or available.
        </div>

        <div :if={@active_channel_id} class="flex-1 flex flex-col w-full h-full">
          <!-- Chat Header -->
          <div class="p-4 border-b shadow-sm z-10 flex items-center bg-white">
            <Heroicons.hashtag class="h-5 w-5 text-gray-400 mr-2" />
            <h2 class="font-bold text-gray-800">
              {Enum.find(@channels, &(to_string(&1.id) == @active_channel_id)).name}
            </h2>
          </div>
          
          <!-- Messages -->
          <div class="flex-1 overflow-y-auto p-4 space-y-4" id="chat-messages" phx-update="stream">
            <div :for={{dom_id, message} <- @streams.messages} id={dom_id} class="flex items-start">
              <img src={message.user.avatar_url || "https://ui-avatars.com/api/?name=#{message.user.username}&size=100"} class="h-10 w-10 rounded-full mr-3" />
              <div>
                <div class="flex items-baseline">
                  <span class="font-bold text-gray-900 mr-2">{message.user.username}</span>
                  <span class="text-xs text-gray-500">{Calendar.strftime(message.inserted_at, "%I:%M %p")}</span>
                </div>
                <div class="text-gray-800 mt-0.5">{message.content}</div>
              </div>
            </div>
          </div>
          
          <!-- Input Area -->
          <div class="p-4 bg-white border-t">
            <.form for={@form} phx-submit="send_message" class="flex items-center bg-gray-100 rounded-lg pr-2">
              <input 
                type="text" 
                name="content" 
                value={@form[:content].value} 
                class="flex-1 bg-transparent border-none focus:ring-0 px-4 py-3 text-gray-700"
                placeholder={"Message ##{Enum.find(@channels, &(to_string(&1.id) == @active_channel_id)).name}"} 
                autocomplete="off"
              />
              <button type="submit" class="p-2 text-indigo-600 hover:text-indigo-800 hover:bg-indigo-50 rounded-md transition duration-150">
                <Heroicons.paper_airplane class="h-5 w-5 rotate-90" />
              </button>
            </.form>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("send_message", %{"content" => content}, socket) do
    if content != "" do
      attrs = %{
        content: content,
        channel_id: String.to_integer(socket.assigns.active_channel_id),
        user_id: socket.assigns.current_user.id
      }
      
      Messaging.create_message(attrs)
    end
    
    {:noreply, assign(socket, :form, to_form(%{"content" => ""}))}
  end

  @impl true
  def handle_info({Messaging, :message_created, message}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
  end
end

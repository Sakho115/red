defmodule EngHubWeb.ChatDrawer do
  use EngHubWeb, :html

  @doc """
  Renders the contextual chat drawer.
  """
  attr :context_id, :string, required: true
  attr :context_type, :string, required: true
  attr :current_user, :map, required: true
  attr :is_open, :boolean, default: false

  def render(assigns) do
    ~H"""
    <aside class={[
      "flex-shrink-0 w-80 bg-base-100 border-l border-base-300 flex flex-col h-full shadow-2xl transition-all duration-300 ease-in-out z-40 transform",
      if(@is_open, do: "translate-x-0 opacity-100 w-80", else: "translate-x-full opacity-0 w-0 border-none")
    ]}>
      <%= if @is_open do %>
        <div class="h-14 border-b border-base-300 flex items-center justify-between px-4 shrink-0 bg-base-100/90 backdrop-blur">
          <div class="flex items-center gap-2">
            <.icon name="hero-chat-bubble-left-ellipsis" class="w-5 h-5 text-base-content/70" />
            <h3 class="font-bold text-sm tracking-tight truncate">
              <%= if @context_type == "thread", do: "Thread Discussion" %>
              <%= if @context_type == "project", do: "Project Chat" %>
            </h3>
          </div>
          <button phx-click="close_chat" class="p-1 rounded-md hover:bg-base-300 text-base-content/50 hover:text-base-content transition-colors">
            <.icon name="hero-x-mark" class="w-5 h-5" />
          </button>
        </div>

        <!-- Chat messages area (mocked for now, will connect to LiveView stream later) -->
        <div class="flex-1 overflow-y-auto p-4 flex flex-col gap-4">
          <div class="text-center text-xs text-base-content/50 my-2 uppercase font-semibold tracking-wider">
            Beginning of context
          </div>
          
          <div class="flex gap-3">
            <div class="avatar placeholder shrink-0">
              <div class="bg-neutral text-neutral-content rounded-full w-8 h-8">
                <span class="text-xs">S</span>
              </div>
            </div>
            <div class="flex flex-col">
              <div class="flex items-baseline gap-2">
                <span class="font-bold text-[13px]">System</span>
                <span class="text-[10px] text-base-content/50">Just now</span>
              </div>
              <p class="text-[14px] text-base-content/90 mt-0.5">Connected to {@context_type} context.</p>
            </div>
          </div>
        </div>

        <div class="p-4 shrink-0 bg-base-200">
          <form phx-submit="send_message" class="relative">
            <input 
              type="text" 
              name="message" 
              placeholder="Type a message..." 
              class="w-full bg-base-100 border border-base-300 rounded-lg px-4 py-2.5 text-[14px] focus:outline-none focus:ring-2 focus:ring-primary/50 transition-all placeholder:text-base-content/30"
              autocomplete="off"
            />
            <button type="submit" class="absolute right-2 top-2 p-1 text-base-content/50 hover:text-primary transition-colors">
              <.icon name="hero-paper-airplane" class="w-5 h-5" />
            </button>
          </form>
        </div>
      <% end %>
    </aside>
    """
  end
end

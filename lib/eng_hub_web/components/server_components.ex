defmodule EngHubWeb.ServerComponents do
  use Phoenix.Component

  use Phoenix.VerifiedRoutes,
    endpoint: EngHubWeb.Endpoint,
    router: EngHubWeb.Router,
    statics: EngHubWeb.static_paths()

  import EngHubWeb.CoreComponents
  alias Phoenix.LiveView.JS

  @doc """
  Renders the server sidebar (leftmost).
  """
  def server_sidebar(assigns) do
    ~H"""
    <nav class="hidden md:flex w-[72px] flex-shrink-0 flex-col items-center py-3 gap-2 select-none glass-server-bar z-50">
      <!-- Home Button -->
      <a
        href="/"
        class="w-12 h-12 flex items-center justify-center transition-all duration-300 cursor-pointer relative group mb-1"
      >
        <div class={[
          "w-12 h-12 flex items-center justify-center transition-all duration-300 shadow-lg",
          "bg-base-100 text-primary hover:bg-primary hover:text-white rounded-[24px] hover:rounded-[15px] animate-server-icon"
        ]}>
          <.icon name="hero-sparkles" class="w-7 h-7" />
        </div>
        
        <!-- Active Pill (Home) -->
        <div class="absolute left-[-4px] top-1/2 -translate-y-1/2 server-pill h-2 group-hover:h-5">
        </div>

        <div class="absolute left-full ml-3 px-3 py-1.5 bg-black text-white text-[13px] font-bold rounded-md shadow-xl opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-[100] pointer-events-none after:content-[''] after:absolute after:right-full after:top-1/2 after:-translate-y-1/2 after:border-8 after:border-transparent after:border-r-black">
          Home
        </div>
      </a>

      <div class="w-8 h-[2px] bg-white/5 rounded-full my-1"></div>

      <!-- Server List -->
      <div class="flex-1 w-full overflow-y-auto custom-scrollbar flex flex-col items-center gap-2">
        <%= for server <- @servers do %>
          <.link
            navigate={~p"/servers/#{server.id}"}
            class="w-full flex items-center justify-center relative group"
          >
            <!-- Active Pill -->
            <div class={[
              "server-pill",
              if(@current_server_id == server.id, do: "h-10", else: "h-2 scale-0 group-hover:scale-100 group-hover:h-5")
            ]}>
            </div>

            <div class={[
              "w-12 h-12 flex items-center justify-center transition-all duration-300 shadow-lg font-bold text-lg animate-server-icon overflow-hidden",
              if(@current_server_id == server.id,
                do: "rounded-[15px] bg-primary text-white",
                else: "rounded-[24px] bg-base-100 text-base-content/70 hover:rounded-[15px] hover:bg-primary hover:text-white"
              )
            ]}>
              {String.at(server.name, 0) |> String.upcase()}
            </div>

            <!-- Tooltip -->
            <div class="absolute left-full ml-3 px-3 py-1.5 bg-black text-white text-[13px] font-bold rounded-md shadow-xl opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-[100] pointer-events-none after:content-[''] after:absolute after:right-full after:top-1/2 after:-translate-y-1/2 after:border-8 after:border-transparent after:border-r-black">
              {server.name}
            </div>
          </.link>
        <% end %>

        <!-- Create Server Button -->
        <button
          phx-click="open_server_form"
          class="w-12 h-12 flex items-center justify-center transition-all duration-300 cursor-pointer relative group mt-1"
        >
          <div class="w-12 h-12 rounded-[24px] bg-base-100 text-success flex items-center justify-center hover:rounded-[15px] hover:bg-success hover:text-white transition-all duration-300 shadow-lg animate-server-icon">
            <.icon name="hero-plus" class="w-6 h-6" />
          </div>
          
          <div class="absolute left-full ml-3 px-3 py-1.5 bg-black text-white text-[13px] font-bold rounded-md shadow-xl opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap z-[100] pointer-events-none after:content-[''] after:absolute after:right-full after:top-1/2 after:-translate-y-1/2 after:border-8 after:border-transparent after:border-r-black">
            Add a Server
          </div>
        </button>
      </div>
    </nav>
    """
  end

  def channel_sidebar(assigns) do
    ~H"""
    <aside class="hidden md:flex w-60 flex-shrink-0 flex-col select-none glass-sidebar z-40">
      <!-- Server Header -->
      <div class="h-12 flex items-center px-4 font-black border-b border-white/5 hover:bg-white/5 cursor-pointer transition-all relative group">
        <span class="truncate tracking-tight text-[15px]">{@server.name}</span>
        <div class="flex-1"></div>
        <.icon name="hero-chevron-down" class="w-4 h-4 text-white/30 group-hover:text-white transition-colors" />
        
        <!-- Dropdown Shadow -->
        <div class="absolute bottom-0 left-0 right-0 h-[1px] bg-black/20 shadow-sm"></div>
      </div>

      <!-- Categories & Channels -->
      <div class="flex-1 overflow-y-auto px-2 py-3 space-y-4 custom-scrollbar">
        <%= for category <- @categories do %>
          <div class="space-y-0.5">
            <div
              class="px-2 py-1 text-[11px] font-black text-white/30 uppercase tracking-[0.05em] flex items-center group cursor-pointer hover:text-white/60 transition-colors"
              phx-click={JS.toggle(to: "#category-#{category.id}-channels")}
            >
              <.icon
                name="hero-chevron-down"
                class="w-3 h-3 mr-0.5 transition-transform [[aria-expanded=false]_&]:-rotate-90"
              />
              <span class="flex-1 truncate">{category.name}</span>
              <button
                phx-click="open_create_channel"
                phx-value-category_id={category.id}
                class="opacity-0 group-hover:opacity-100 transition-opacity p-0.5 hover:text-white"
              >
                <.icon name="hero-plus" class="w-3.5 h-3.5" />
              </button>
            </div>

            <div id={"category-#{category.id}-channels"} class="space-y-0.5" phx-update="replace">
              <%= for channel <- category.channels do %>
                <.channel_link
                  channel={channel}
                  active={@current_channel_id == channel.id}
                  server_id={@server.id}
                />
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
      
      <!-- User Profile Bar -->
      <div class="px-2 py-1.5 bg-black/20 mt-auto border-t border-white/5 flex items-center gap-2 shrink-0 glass-surface">
        <div class="relative cursor-pointer group">
          <div class="w-8 h-8 rounded-full bg-primary flex items-center justify-center text-white font-black text-xs shadow-inner shadow-white/20">
            {String.at(@current_user.email, 0) |> String.upcase()}
          </div>
          <div class="absolute bottom-[-1px] right-[-1px] w-3 h-3 bg-success rounded-full border-[2.5px] border-base-200">
          </div>
          
          <!-- Quick Status Tooltip -->
          <div class="absolute bottom-full left-0 mb-2 px-2 py-1 bg-black text-white text-[10px] font-bold rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap pointer-events-none">
            Online
          </div>
        </div>
        
        <div class="flex-1 min-w-0 cursor-pointer group">
          <div class="text-[13px] font-bold text-white leading-tight truncate">
            {@current_user.email |> String.split("@") |> List.first()}
          </div>
          <div class="text-[11px] text-white/30 truncate leading-tight group-hover:text-white/50 transition-colors tracking-tight">
            #1337
          </div>
        </div>
        
        <div class="flex gap-0">
          <button class="w-8 h-8 rounded-md flex items-center justify-center text-white/40 hover:text-white hover:bg-white/5 transition-all">
            <.icon name="hero-microphone" class="w-4.5 h-4.5" />
          </button>
          <button class="w-8 h-8 rounded-md flex items-center justify-center text-white/40 hover:text-white hover:bg-white/5 transition-all">
            <.icon name="hero-speaker-wave" class="w-4.5 h-4.5" />
          </button>
          <button class="w-8 h-8 rounded-md flex items-center justify-center text-white/40 hover:text-white hover:bg-white/5 transition-all">
            <.icon name="hero-cog-6-tooth" class="w-4.5 h-4.5" />
          </button>
        </div>
      </div>
    </aside>
    """
  end

  defp channel_link(assigns) do
    icon =
      case assigns.channel.type do
        :general_chat -> "hero-hashtag"
        :project -> "hero-briefcase"
        :posts -> "hero-chat-bubble-left-ellipsis"
        :threads -> "hero-queue-list"
        :files -> "hero-document"
        :hackathon -> "hero-trophy"
        _ -> "hero-hashtag"
      end

    assigns = assign(assigns, :icon, icon)

    ~H"""
    <.link
      navigate={~p"/servers/#{@server_id}/channels/#{@channel.id}"}
      class={[
        "flex items-center gap-1.5 px-2 py-1.5 rounded-md text-[14px] font-medium transition-all group",
        if(@active,
          do: "bg-white/10 text-white shadow-sm ring-1 ring-white/5",
          else: "text-white/40 hover:bg-white/5 hover:text-white/80"
        )
      ]}
    >
      <.icon
        name={@icon}
        class={["w-4.5 h-4.5", if(@active, do: "text-white", else: "text-white/30 group-hover:text-white/50")]}
      />
      <span class="truncate leading-[1.1]">{@channel.name}</span>
      
      <div class="ml-auto opacity-0 group-hover:opacity-100 flex gap-1">
        <button class="text-white/20 hover:text-white transition-colors">
          <.icon name="hero-user-plus" class="w-3.5 h-3.5" />
        </button>
        <button class="text-white/20 hover:text-white transition-colors">
          <.icon name="hero-cog-8-tooth" class="w-3.5 h-3.5" />
        </button>
      </div>
    </.link>
    """
  end
end

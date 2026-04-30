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
    <nav class="hidden md:flex w-[72px] shrink-0 flex-col items-center py-3 gap-2 select-none glass-server-bar z-50">
      <!-- Home Button -->
      <.link
        navigate={~p"/home"}
        class="w-12 h-12 flex items-center justify-center transition-all duration-300 cursor-pointer relative group active-scale"
      >
        <div class={[
          "w-12 h-12 flex items-center justify-center transition-all duration-300 shadow-md",
          if(is_nil(@current_server_id),
            do: "bg-primary text-white rounded-[16px]",
            else:
              "bg-base-100 text-white/50 hover:bg-primary hover:text-white rounded-[24px] hover:rounded-[16px]"
          ),
          "hover-lift shadow-inner"
        ]}>
          <.icon name="hero-sparkles" class="w-6 h-6" />
        </div>
        
    <!-- Active Pill (Home) -->
        <div class={[
          "server-pill",
          if(is_nil(@current_server_id),
            do: "h-10",
            else: "h-2 scale-0 group-hover:scale-100 group-hover:h-5"
          )
        ]}>
        </div>
        
    <!-- Tooltip -->
        <div class="premium-tooltip">Home</div>
      </.link>

      <div class="w-8 h-[2px] bg-white/5 rounded-full my-1 shrink-0"></div>
      
    <!-- Server List -->
      <div class="flex-1 w-full overflow-y-auto custom-scrollbar flex flex-col items-center gap-2 px-2 pb-4">
        <%= for server <- @servers do %>
          <.link
            navigate={~p"/s/#{server.id}"}
            class="w-12 h-12 flex items-center justify-center relative group active-scale"
          >
            <!-- Active Pill -->
            <div class={[
              "server-pill",
              if(@current_server_id == server.id,
                do: "h-10",
                else: "h-2 scale-0 group-hover:scale-100 group-hover:h-5"
              )
            ]}>
            </div>

            <div class={[
              "w-12 h-12 flex items-center justify-center transition-all duration-300 shadow-lg font-bold text-[18px] animate-server-icon overflow-hidden",
              if(@current_server_id == server.id,
                do: "rounded-[16px] bg-primary text-white",
                else:
                  "rounded-[24px] bg-base-100 text-base-content/70 hover:rounded-[16px] hover:bg-primary hover:text-white"
              ),
              "shadow-inner"
            ]}>
              {String.at(server.name, 0) |> String.upcase()}
            </div>
            
    <!-- Tooltip -->
            <div class="premium-tooltip">{server.name}</div>
          </.link>
        <% end %>
        
    <!-- Create Server Button -->
        <button
          phx-click="open_server_form"
          class="w-12 h-12 flex items-center justify-center transition-all duration-300 cursor-pointer relative group shrink-0 active-scale"
        >
          <div class="w-12 h-12 rounded-[24px] bg-base-100 text-success flex items-center justify-center hover:rounded-[16px] hover:bg-success hover:text-white transition-all duration-300 shadow-md">
            <.icon name="hero-plus" class="w-6 h-6" />
          </div>

          <div class="premium-tooltip text-success">Add a Server</div>
        </button>
      </div>
    </nav>
    """
  end

  def channel_sidebar(assigns) do
    ~H"""
    <aside class="hidden md:flex w-60 flex-shrink-0 flex-col select-none glass-sidebar z-40">
      <%= if @server do %>
        <!-- Server Header -->
        <div
          class="h-12 flex items-center px-3 font-bold hover:bg-white/[0.03] cursor-pointer transition-colors border-b border-black/10 relative group"
          phx-click="open_server_settings"
        >
          <span class="truncate tracking-tight text-[15px] text-white/90">{@server.name}</span>
          <div class="flex-1"></div>
          <.icon
            name="hero-chevron-down"
            class="w-4 h-4 text-white/40 group-hover:text-white transition-colors"
          />
        </div>
        
    <!-- Categories & Channels -->
        <div class="flex-1 overflow-y-auto px-1.5 py-2 space-y-3 custom-scrollbar">
          <%= for category <- @categories do %>
            <div id={"cat-wrap-#{category.id}"} class="space-y-px">
              <div
                class="px-2 h-6 text-[11px] font-bold text-white/30 uppercase tracking-[0.05em] flex items-center group cursor-pointer hover:text-white/60 transition-colors"
                phx-click={
                  JS.toggle(to: "#category-#{category.id}-channels")
                  |> JS.toggle_class("collapsed", to: "#cat-wrap-#{category.id}")
                }
              >
                <.icon
                  name="hero-chevron-down"
                  class="w-3 h-3 mr-1 rotate-collapse opacity-40 group-hover:opacity-100"
                />
                <span class="flex-1 truncate">
                  {if(Map.get(category, :emoji), do: "#{category.emoji} ", else: "")}{category.name}
                </span>
                <button
                  phx-click="open_create_channel"
                  phx-value-category_id={category.id}
                  class="opacity-0 group-hover:opacity-100 transition-opacity p-0.5 hover:text-white"
                >
                  <.icon name="hero-plus" class="w-3 h-3" />
                </button>
              </div>

              <div id={"category-#{category.id}-channels"} class="space-y-px" phx-update="replace">
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
      <% else %>
        <!-- Home / DM Sidebar -->
        <div class="h-12 flex items-center px-3 border-b border-white/5">
          <div class="w-full bg-black/20 rounded-md h-7 flex items-center px-2 text-[13px] text-white/20 font-medium cursor-pointer hover:bg-black/30 transition-all">
            Find or start a conversation
          </div>
        </div>

        <div class="flex-1 overflow-y-auto px-2 py-3 space-y-0.5 custom-scrollbar">
          <!-- DM Nav links -->
          <.link
            navigate={~p"/home"}
            class={[
              "flex items-center gap-2 px-2 h-8 rounded-md transition-all group",
              if(assigns[:active_tab] == :friends,
                do: "bg-white/10 text-white",
                else: "text-white/40 hover:bg-white/5 hover:text-white/80"
              )
            ]}
          >
            <.icon
              name="hero-users"
              class={[
                "w-4 h-4 shrink-0",
                if(assigns[:active_tab] == :friends,
                  do: "text-white",
                  else: "text-white/30 group-hover:text-white/50"
                )
              ]}
            />
            <span class="font-semibold text-[13px]">Friends</span>
          </.link>

          <.link
            navigate={~p"/discovery"}
            class={[
              "flex items-center gap-2 px-2 h-8 rounded-md transition-all group",
              if(assigns[:active_tab] == :discovery,
                do: "bg-white/10 text-white",
                else: "text-white/40 hover:bg-white/5 hover:text-white/80"
              )
            ]}
          >
            <.icon
              name="hero-compass"
              class={[
                "w-4 h-4 shrink-0",
                if(assigns[:active_tab] == :discovery,
                  do: "text-white",
                  else: "text-white/30 group-hover:text-white/50"
                )
              ]}
            />
            <span class="font-semibold text-[13px]">Discovery</span>
          </.link>

          <.link
            navigate={~p"/app-directory"}
            class={[
              "flex items-center gap-2 px-2 h-8 rounded-md transition-all group",
              if(assigns[:active_tab] == :apps,
                do: "bg-white/10 text-white",
                else: "text-white/40 hover:bg-white/5 hover:text-white/80"
              )
            ]}
          >
            <.icon
              name="hero-cube-transparent"
              class={[
                "w-4 h-4 shrink-0",
                if(assigns[:active_tab] == :apps,
                  do: "text-white",
                  else: "text-white/30 group-hover:text-white/50"
                )
              ]}
            />
            <span class="font-semibold text-[13px]">App Directory</span>
          </.link>

          <div class="pt-3 pb-1 px-1 flex justify-between items-center group/dm">
            <span class="text-[10px] font-black text-white/20 uppercase tracking-[0.1em]">Direct Messages</span>
            <button class="text-white/30 hover:text-white opacity-0 group-hover/dm:opacity-100 transition-all">
              <.icon name="hero-plus" class="w-4 h-4" />
            </button>
          </div>
          
    <!-- Active DM Channels List -->
          <div class="space-y-0.5" id="dm-list">
            <%= for channel <- assigns[:dm_channels] || [] do %>
              <% # Find the other user in the DM
              other_member = Enum.find(channel.members || [], &(&1.id != @current_user.id))
              other_user_email = (other_member || @current_user).email
              display_name = String.split(other_user_email, "@") |> List.first()

              online? =
                to_string((other_member || @current_user).id) in Enum.map(
                  assigns[:online_user_ids] || [],
                  &to_string/1
                ) %>
              <.link
                navigate={~p"/dms/#{channel.id}"}
                class={[
                  "w-full text-left flex items-center gap-2 px-2 h-8 rounded-[4px] group transition-all",
                  if(@current_channel_id == channel.id,
                    do: "bg-white/[0.08] text-white",
                    else: "text-white/40 hover:bg-white/[0.04] hover:text-white/80"
                  )
                ]}
              >
                <div class="relative shrink-0">
                  <div class="w-6 h-6 rounded-full bg-white/5 flex items-center justify-center text-white/40 font-bold text-[10px] ring-1 ring-white/5">
                    {String.at(display_name, 0) |> String.upcase()}
                  </div>
                  <%= if online? do %>
                    <div class="absolute bottom-[-1px] right-[-1px] w-2 h-2 bg-success rounded-full border border-base-200">
                    </div>
                  <% end %>
                </div>
                <span class="text-[13px] font-medium truncate leading-none">
                  {display_name}
                </span>
              </.link>
            <% end %>

            <%= if Enum.empty?(assigns[:dm_channels] || []) do %>
              <div class="px-2 py-8 text-center">
                <p class="text-[11px] text-white/20 italic">No active conversations...</p>
              </div>
            <% end %>
          </div>
        </div>
      <% end %>
      
    <!-- User Profile Bar -->
      <div class="px-2 py-1.5 bg-black/20 mt-auto border-t border-white/5 flex items-center gap-2 shrink-0 glass-surface h-[52px]">
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

        <div class="flex-1 min-w-0 cursor-pointer group px-0.5">
          <div class="text-[13px] font-bold text-white/90 leading-tight truncate">
            {@current_user.email |> String.split("@") |> List.first()}
          </div>
          <div class="text-[11px] text-white/20 truncate leading-tight group-hover:text-white/40 transition-colors tracking-tight font-medium">
            #1337
          </div>
        </div>

        <div class="flex gap-0">
          <button
            phx-click="toggle_mute"
            class={[
              "w-8 h-8 rounded-md flex items-center justify-center transition-all relative group/btn",
              if(assigns[:muted],
                do: "text-error",
                else: "text-white/40 hover:text-white hover:bg-white/5"
              )
            ]}
          >
            <.icon
              name={if(assigns[:muted], do: "hero-microphone-solid", else: "hero-microphone")}
              class="w-4.5 h-4.5"
            />
            <%= if assigns[:muted] do %>
              <div class="absolute inset-0 flex items-center justify-center pointer-events-none">
                <div class="w-5 h-[2px] bg-error rotate-45 rounded-full shadow-sm"></div>
              </div>
            <% end %>
          </button>

          <button
            phx-click="toggle_deafen"
            class={[
              "w-8 h-8 rounded-md flex items-center justify-center transition-all relative group/btn",
              if(assigns[:deafened],
                do: "text-error",
                else: "text-white/40 hover:text-white hover:bg-white/5"
              )
            ]}
          >
            <.icon
              name={if(assigns[:deafened], do: "hero-speaker-wave-solid", else: "hero-speaker-wave")}
              class="w-4.5 h-4.5"
            />
            <%= if assigns[:deafened] do %>
              <div class="absolute inset-0 flex items-center justify-center pointer-events-none">
                <div class="w-5 h-[2px] bg-error rotate-45 rounded-full shadow-sm"></div>
              </div>
            <% end %>
          </button>

          <.link
            navigate={~p"/settings/user/profile"}
            class="w-8 h-8 rounded-md flex items-center justify-center text-white/40 hover:text-white hover:bg-white/5 transition-all outline-none"
          >
            <.icon name="hero-cog-6-tooth" class="w-4.5 h-4.5" />
          </.link>
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
        :listings -> "hero-shopping-bag"
        :hackathons -> "hero-trophy"
        _ -> "hero-hashtag"
      end

    assigns = assign(assigns, :icon, icon)

    ~H"""
    <.link
      navigate={~p"/s/#{@server_id}/c/#{@channel.id}"}
      class={[
        "flex items-center gap-1.5 px-2 h-[30px] rounded-[4px] text-[13.5px] font-medium transition-all group relative",
        if(@active,
          do: "bg-white/[0.08] text-white",
          else: "text-white/40 hover:bg-white/[0.04] hover:text-white/80"
        )
      ]}
    >
      <%= if @active do %>
        <div class="channel-active-indicator" />
      <% end %>
      <.icon
        name={@icon}
        class={[
          "w-4.5 h-4.5 flex-shrink-0",
          if(@active, do: "text-white", else: "text-white/30 group-hover:text-white/60")
        ]}
      />
      <span class="truncate leading-none">{@channel.name}</span>

      <div class="ml-auto opacity-0 group-hover:opacity-100 flex gap-1">
        <button
          phx-click="open_invite_modal"
          phx-value-id={@channel.id}
          class="text-white/20 hover:text-white transition-colors p-0.5"
        >
          <.icon name="hero-user-plus" class="w-3.5 h-3.5" />
        </button>
        <button
          phx-click="open_channel_settings"
          phx-value-id={@channel.id}
          class="text-white/20 hover:text-white transition-colors p-0.5"
        >
          <.icon name="hero-cog-8-tooth" class="w-3.5 h-3.5" />
        </button>
      </div>
    </.link>
    """
  end
end

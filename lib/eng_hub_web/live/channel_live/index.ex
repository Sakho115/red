defmodule EngHubWeb.ChannelLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Communities
  alias EngHub.Messaging
  alias EngHub.Projects
  alias EngHub.Timeline
  alias EngHub.Discussions
  alias EngHub.Vault
  alias EngHub.Events

  @impl true
  def mount(params, _session, socket) do
    user_id = socket.assigns.current_user.id
    server_id = params["server_id"]

    # Load servers for the sidebar
    servers = Communities.list_user_servers(user_id)

    # Determine active server
    case resolve_server(server_id, servers) do
      {:ok, server, categories} ->
        if connected?(socket) do
          Phoenix.PubSub.subscribe(EngHub.PubSub, "server:#{server.id}")
          
          # Track presence
          user = socket.assigns.current_user
          EngHubWeb.Presence.track(self(), "server:#{server.id}", user.id, %{
            username: user.email |> String.split("@") |> List.first(),
            role: Communities.get_server_member(server.id, user.id).role
          })
        end

        all_channels = categories |> Enum.flat_map(& &1.channels)
        active_channel = resolve_channel(params["id"], all_channels)
        active_channel_id = active_channel && to_string(active_channel.id)

        # Fetch members and online status
        members = Communities.list_server_members(server.id)
        online_users = EngHubWeb.Presence.list("server:#{server.id}")

        socket =
          socket
          |> assign(:servers, servers)
          |> assign(:server, server)
          |> assign(:categories, categories)
          |> assign(:members, members)
          |> assign(:online_user_ids, Map.keys(online_users))
          |> assign(:active_channel, active_channel)
          |> assign(:active_channel_id, active_channel_id)
          |> assign(:modal, nil)
          |> assign(:channel_form, nil)
          |> assign(:selected_category_id, nil)
          |> setup_channel_context(active_channel)

        {:ok, socket}

      {:error, :not_found} ->
        {:ok, push_navigate(socket, to: ~p"/servers")}

      {:redirect, server_id} ->
        {:ok, push_navigate(socket, to: ~p"/servers/#{server_id}")}

      {:no_servers} ->
        # No servers found, maybe show a welcome/intro or "create your first server"
        {:ok,
         assign(socket,
           servers: [],
           server: nil,
           categories: [],
           active_channel: nil,
           active_channel_id: nil,
           modal: nil,
           channel_form: nil,
           server_form: nil,
           selected_category_id: nil,
           members: [],
           online_user_ids: []
         )}
    end
  end

  defp resolve_server(nil, []), do: {:no_servers}
  defp resolve_server(nil, [first | _]), do: {:redirect, first.id}

  defp resolve_server(id, _servers) do
    case Communities.get_server_tree(id) do
      {server, categories} when not is_nil(server) -> {:ok, server, categories}
      _ -> {:error, :not_found}
    end
  rescue
    _ -> {:error, :not_found}
  end

  defp resolve_channel(nil, channels), do: List.first(channels)

  defp resolve_channel(id, channels) do
    Enum.find(channels, &(to_string(&1.id) == id)) || List.first(channels)
  end

  defp setup_channel_context(socket, nil), do: socket

  defp setup_channel_context(socket, channel) do
    case channel.type do
      :general_chat ->
        if connected?(socket) do
          Messaging.subscribe(to_string(channel.id))
          Phoenix.PubSub.subscribe(EngHub.PubSub, "typing:#{channel.id}")
        end

        messages = 
          Messaging.list_messages_by_channel(channel.id)
          |> Enum.map_reduce(nil, fn msg, last_msg -> 
               continuous? = last_msg && last_msg.user_id == msg.user_id && 
                            DateTime.diff(msg.inserted_at, last_msg.inserted_at) < 300
               {Map.put(msg, :continuous?, continuous?), msg}
             end)
          |> elem(0)

        socket
        |> stream(:messages, messages, reset: true)
        |> assign(:form, to_form(%{"content" => ""}))
        |> assign(:typing_users, %{})
        |> assign(:last_message_meta, List.last(messages) && %{user_id: List.last(messages).user_id, inserted_at: List.last(messages).inserted_at})

      :project ->
        # Use the linked project_id
        project =
          if channel.project_id do
            Projects.get_project!(channel.project_id)
          else
            nil
          end

        assign(socket, :project, project)

      :posts ->
        posts = Timeline.list_posts_by_channel(channel.id)
        stream(socket, :posts, posts, reset: true)

      :threads ->
        threads = Discussions.list_threads_by_channel(channel.id)
        stream(socket, :threads, threads, reset: true)

      :files ->
        files = Vault.list_files_by_channel(channel.id)
        stream(socket, :files, files, reset: true)

      :hackathons ->
        events = Events.list_events_by_channel(channel.id)
        socket |> assign(:events, events) |> stream(:events, events, reset: true)

      _ ->
        socket
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app
      flash={@flash}
      current_scope={@current_user}
      server={@server}
      servers={@servers}
      categories={@categories}
      members={@members}
      active_channel={@active_channel}
      online_user_ids={assigns[:online_user_ids] || []}
    >
      <div class="flex-1 flex flex-col min-w-0 bg-base-100 h-full overflow-hidden relative">
        <%= if @active_channel do %>
          <!-- Header -->
          <header class="h-12 px-4 flex items-center shadow-sm border-b border-white/5 bg-base-100/80 backdrop-blur-md shrink-0 z-20">
            <div class="flex items-center gap-2 min-w-0 mr-4">
              <.icon
                name={get_channel_icon(@active_channel.type)}
                class="h-5 w-5 text-base-content/40 shrink-0"
              />
              <h2 class="font-bold text-[15px] truncate text-base-content">{@active_channel.name}</h2>
            </div>

            <div class="w-[1px] h-5 bg-white/5 mx-2 hidden sm:block"></div>
            <p class="text-[12px] text-base-content/40 hidden lg:block truncate max-w-md italic">
              {get_channel_description(@active_channel)}
            </p>

            <div class="ml-auto flex items-center gap-4 text-base-content/40">
              <button class="hover:text-base-content transition-colors"><.icon name="hero-hashtag" class="h-5 w-5" /></button>
              <button class="hover:text-base-content transition-colors"><.icon name="hero-bell" class="h-5 w-5" /></button>
              <button class="hover:text-base-content transition-colors"><.icon name="hero-users" class="h-5 w-5" /></button>

              <div class="relative group hidden sm:block">
                <.icon name="hero-magnifying-glass" class="h-3.5 w-3.5 absolute right-2 top-1/2 -translate-y-1/2 text-white/20" />
                <input type="text" placeholder="Search" class="bg-black/20 border-white/5 rounded-md h-7 text-xs pr-7 w-32 focus:w-48 transition-all focus:ring-1 ring-primary/30 text-white placeholder:text-white/20" />
              </div>

              <button class="hover:text-base-content transition-colors"><.icon name="hero-inbox" class="h-5 w-5" /></button>
              <button class="hover:text-base-content transition-colors"><.icon name="hero-question-mark-circle" class="h-5 w-5" /></button>
            </div>
          </header>
          
          <!-- Content Switcher -->
          <div class="flex-1 overflow-hidden flex min-h-0 relative">
            {render_channel_content(assigns)}
          </div>
        <% else %>
          <div class="flex-1 flex flex-col items-center justify-center p-12 text-center h-full">
            <div class="w-24 h-24 bg-gradient-to-br from-primary/20 to-secondary/20 rounded-[32px] flex items-center justify-center mb-6 shadow-inner animate-pulse">
              <.icon name="hero-sparkles" class="h-12 w-12 text-primary/40" />
            </div>
            <h2 class="text-3xl font-black text-base-content mb-3 uppercase tracking-tighter">
              Welcome to {(@server && @server.name) || "EngHub"}
            </h2>
            <p class="text-base-content/60 max-w-sm mb-8 leading-relaxed">
              Select a channel from the left sidebar to dive into the engineering collaboration workspace.
            </p>
          </div>
        <% end %>
      </div>

      <%= if @modal == :create_channel do %>
        <.create_channel_modal
          channel_form={@channel_form}
          categories={@categories}
          selected_category_id={@selected_category_id}
        />
      <% end %>

      <%= if @modal == :create_server do %>
        <.create_server_modal
          server_form={@server_form}
        />
      <% end %>
    </Layouts.app>
    """
  end

  defp get_channel_icon(type) do
    case type do
      :general_chat -> "hero-hashtag"
      :project -> "hero-briefcase"
      :posts -> "hero-chat-bubble-left-ellipsis"
      :threads -> "hero-queue-list"
      :files -> "hero-document"
      :listings -> "hero-shopping-bag"
      :hackathons -> "hero-trophy"
      _ -> "hero-hashtag"
    end
  end

  defp get_channel_description(channel) do
    case channel.type do
      :general_chat -> "Real-time communication and team discussions."
      :project -> "Integrated engineering workspace and project management."
      :posts -> "Global community updates and project reveals."
      :threads -> "Deep-dive technical discussions and Q&A."
      :files -> "Secure resource storage and version control."
      :hackathons -> "Upcoming engineering competitions and events."
      _ -> "Welcome to the channel!"
    end
  end

  # Channel Content Renderers

  defp render_channel_content(%{active_channel: %{type: :general_chat}} = assigns) do
    ~H"""
    <div class="flex-1 flex flex-col min-w-0 bg-base-100">
      <div
        class="flex-1 overflow-y-auto px-4 py-2 space-y-0 custom-scrollbar"
        id="chat-messages"
        phx-update="stream"
      >
        <div
          :for={{dom_id, message} <- @streams.messages}
          id={dom_id}
          class={[
            "group flex items-start px-4 py-[2px] hover:bg-white/[0.02] -mx-4 transition-colors relative",
            Map.get(message, :continuous?) && "mt-[-2px]"
          ]}
        >
          <!-- Hover Actions bar -->
          <div class="absolute right-4 top-[-20px] bg-base-200 border border-white/5 rounded-md shadow-xl flex opacity-0 group-hover:opacity-100 transition-opacity z-10 overflow-hidden">
            <button class="p-2 hover:bg-white/5 text-white/50 hover:text-white transition-all"><.icon name="hero-face-smile" class="w-4 h-4" /></button>
            <button class="p-2 hover:bg-white/5 text-white/50 hover:text-white transition-all"><.icon name="hero-pencil" class="w-4 h-4" /></button>
            <button class="p-2 hover:bg-white/5 text-white/50 hover:text-white transition-all"><.icon name="hero-arrow-uturn-left" class="w-4 h-4" /></button>
            <button class="p-2 hover:bg-white/5 text-white/50 hover:text-white transition-all"><.icon name="hero-ellipsis-horizontal" class="w-4 h-4" /></button>
          </div>

          <%= if !Map.get(message, :continuous?) do %>
            <div class="h-10 w-10 shrink-0 rounded-[12px] bg-primary flex items-center justify-center text-white font-black text-sm mr-4 mt-1.5 shadow-inner shadow-white/20">
              {String.at(message.user.email, 0) |> String.upcase()}
            </div>
          <% else %>
            <div class="w-10 mr-4 flex justify-center opacity-0 group-hover:opacity-100 transition-opacity">
              <span class="text-[9px] text-white/20 mt-1.5 font-medium tabular-nums">
                {Calendar.strftime(message.inserted_at, "%H:%M")}
              </span>
            </div>
          <% end %>

          <div class="min-w-0 flex-1">
            <%= if !Map.get(message, :continuous?) do %>
              <div class="flex items-baseline gap-2 mb-0.5">
                <span class="font-black text-[15px] text-white hover:underline cursor-pointer tracking-tight">
                  {message.user.email |> String.split("@") |> List.first()}
                </span>
                <span class="text-[11px] text-white/20 font-bold uppercase tracking-widest">
                  {Calendar.strftime(message.inserted_at, "%I:%M %p")}
                </span>
              </div>
            <% end %>
            <div class="text-white/80 text-[15px] leading-[1.4] break-words tracking-normal">
              {message.content}
            </div>
          </div>
        </div>
      </div>

      <!-- Typing Indicator & Input Bar -->
      <div class="px-4 pb-6 pt-1 shrink-0">
        <div class="h-6 flex items-center px-1 mb-1">
          <%= if map_size(@typing_users) > 0 do %>
            <div class="flex items-center gap-2 animate-in fade-in slide-in-from-bottom-2 duration-300">
              <div class="flex gap-1">
                <div class="w-1.5 h-1.5 bg-white/30 rounded-full animate-bounce"></div>
                <div class="w-1.5 h-1.5 bg-white/30 rounded-full animate-bounce [animation-delay:0.2s]"></div>
                <div class="w-1.5 h-1.5 bg-white/30 rounded-full animate-bounce [animation-delay:0.4s]"></div>
              </div>
              <span class="text-[12px] font-bold text-white/40 tracking-tight italic">
                <%= if map_size(@typing_users) == 1 do %>
                  <span class="text-white/60">{Enum.at(Map.values(@typing_users), 0)}</span> is typing...
                <% else %>
                  Several people are typing...
                <% end %>
              </span>
            </div>
          <% end %>
        </div>

        <.form
          for={@form}
          phx-submit="send_message"
          phx-change="typing"
          class="bg-white/5 rounded-xl px-4 flex items-center gap-3 border border-white/5 focus-within:border-primary/50 transition-all duration-300 shadow-xl"
        >
          <button type="button" class="text-white/30 hover:text-white transition-all transform hover:scale-110 active:scale-95">
            <.icon name="hero-plus-circle-solid" class="w-6 h-6" />
          </button>
          <input
            type="text"
            name="content"
            value={@form[:content].value}
            class="flex-1 bg-transparent border-none focus:ring-0 text-[15px] py-3 text-white placeholder:text-white/10"
            placeholder={"Message ##{@active_channel.name}"}
            autocomplete="off"
          />
          <div class="flex items-center gap-3 text-white/30">
            <button type="button" class="hover:text-primary transition-all transform hover:scale-110">
              <.icon name="hero-gift" class="w-5 h-5" />
            </button>
            <button type="button" class="hover:text-primary transition-all transform hover:scale-110">
              <.icon name="hero-face-smile" class="w-5 h-5" />
            </button>
          </div>
        </.form>
      </div>
    </div>
    """
  end

  defp render_channel_content(%{active_channel: %{type: :project}} = assigns) do
    ~H"""
    <div class="flex-1 overflow-y-auto bg-base-100 p-8 custom-scrollbar">
      <%= if @project do %>
        <div class="max-w-4xl mx-auto">
          <div class="flex items-center justify-between mb-12">
            <div class="flex items-center gap-6">
              <div class="h-20 w-20 bg-gradient-to-br from-primary to-secondary rounded-[24px] flex items-center justify-center shadow-xl shadow-primary/20 rotate-3">
                <.icon name="hero-cpu-chip" class="h-12 w-12 text-primary-content" />
              </div>
              <div>
                <h1 class="text-4xl font-black text-base-content tracking-tighter uppercase whitespace-pre-wrap leading-none mb-2">
                  {@project.name}
                </h1>
                <div class="flex items-center gap-2">
                  <span class="px-2 py-0.5 bg-primary/10 text-primary text-[10px] font-bold rounded uppercase tracking-wider">
                    Active Workspace
                  </span>
                  <span class="text-base-content/40 text-xs font-medium italic">
                    Managed via {@active_channel.name}
                  </span>
                </div>
              </div>
            </div>

            <div class="flex gap-2">
              <button class="px-4 py-2 bg-base-200 hover:bg-base-300 rounded-lg text-sm font-bold transition-colors">
                Settings
              </button>
              <button class="px-4 py-2 bg-primary text-primary-content rounded-lg text-sm font-bold shadow-lg shadow-primary/20 hover:scale-105 transition-transform">
                Deploy
              </button>
            </div>
          </div>

          <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-12">
            <div class="col-span-2 space-y-6">
              <div class="bg-base-200/50 border border-base-300 p-6 rounded-2xl">
                <h3 class="text-base-content font-bold mb-4 flex items-center gap-2">
                  <.icon name="hero-list-bullet" class="w-5 h-5 text-primary" /> Description
                </h3>
                <p class="text-base-content/70 leading-relaxed italic">{@project.description}</p>
              </div>

              <div class="bg-base-200/50 border border-base-300 p-6 rounded-2xl">
                <h3 class="text-base-content font-bold mb-4 flex items-center gap-2">
                  <.icon name="hero-chart-bar" class="w-5 h-5 text-secondary" /> Recent Activity
                </h3>
                <div class="space-y-4">
                  <div
                    :for={i <- 1..3}
                    class="flex items-start gap-4 p-3 rounded-xl hover:bg-base-200 transition-colors cursor-pointer group"
                  >
                    <div class="h-1.5 w-1.5 rounded-full bg-primary mt-2"></div>
                    <div class="flex-1">
                      <div class="text-sm font-bold group-hover:text-primary transition-colors">
                        Feature refinement implemented in Phase {i}
                      </div>
                      <div class="text-[11px] text-base-content/40 uppercase font-black tracking-widest mt-1">
                        2 hours ago
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            <div class="space-y-6">
              <div class="bg-gradient-to-br from-primary/10 to-secondary/10 border border-primary/20 p-6 rounded-2xl">
                <h3 class="text-base-content font-black text-xs uppercase tracking-widest mb-4">
                  Contributors
                </h3>
                <div class="flex flex-wrap gap-2">
                  <div
                    :for={i <- 1..6}
                    class="w-10 h-10 rounded-[12px] bg-base-300 flex items-center justify-center font-bold text-xs border border-base-100 shadow-sm hover:scale-110 transition-transform cursor-pointer"
                  >
                    {String.at("Developer", i - 1) |> String.upcase()}
                  </div>
                </div>
              </div>

              <div class="bg-base-900 border border-base-800 p-6 rounded-2xl shadow-2xl">
                <h3 class="text-white font-bold text-xs uppercase tracking-widest mb-4">
                  Quick Actions
                </h3>
                <div class="space-y-2">
                  <button class="w-full text-left px-3 py-2 rounded-lg hover:bg-primary/20 text-[13px] text-white/70 hover:text-white transition-all flex items-center justify-between group">
                    Open in Vault
                    <.icon name="hero-arrow-right" class="w-4 h-4 opacity-0 group-hover:opacity-100" />
                  </button>
                  <button class="w-full text-left px-3 py-2 rounded-lg hover:bg-primary/20 text-[13px] text-white/70 hover:text-white transition-all flex items-center justify-between group">
                    Invite Engineers
                    <.icon name="hero-plus" class="w-4 h-4 opacity-0 group-hover:opacity-100" />
                  </button>
                </div>
              </div>
            </div>
          </div>
        </div>
      <% else %>
        <div class="flex-1 flex flex-col items-center justify-center h-full text-center">
          <div class="w-24 h-24 bg-base-200 rounded-[32px] flex items-center justify-center mb-6 border-dashed border-2 border-base-300">
            <.icon name="hero-briefcase" class="h-10 w-10 text-base-content/20" />
          </div>
          <h3 class="text-xl font-bold mb-2">No Project Linked</h3>
          <p class="text-base-content/50 max-w-xs mb-6">
            This channel represents a project workspace but no active project was found or linked.
          </p>
          <button class="bg-primary text-primary-content font-bold px-6 py-2 rounded-lg shadow-lg shadow-primary/20">
            Link Project
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  defp render_channel_content(%{active_channel: %{type: :posts}} = assigns) do
    ~H"""
    <div class="flex-1 overflow-y-auto bg-base-200/30 p-8 custom-scrollbar">
      <div class="max-w-2xl mx-auto" phx-update="stream" id="posts-feed">
        <div
          :for={{dom_id, post} <- @streams.posts}
          id={dom_id}
          class="bg-base-100 border border-base-300 rounded-[20px] overflow-hidden shadow-sm mb-6 hover:shadow-md transition-shadow"
        >
          <div class="p-5 flex items-center gap-3">
            <div class="h-10 w-10 rounded-full bg-secondary/20 flex items-center justify-center text-secondary font-bold">
              {String.at(post.user.email, 0)}
            </div>
            <div>
              <div class="text-base-content font-black text-sm tracking-tight">
                {post.user.email |> String.split("@") |> List.first()}
              </div>
              <div class="text-[10px] text-base-content/40 uppercase font-black tracking-widest">
                {Calendar.strftime(post.inserted_at, "%B %d, %Y")}
              </div>
            </div>
            <button class="ml-auto text-base-content/30 hover:text-base-content transition-colors">
              <.icon name="hero-ellipsis-horizontal" class="h-5 w-5" />
            </button>
          </div>

          <div class="px-6 pb-6 text-base-content/80 text-[16px] leading-relaxed font-medium italic">
            {post.body}
          </div>

          <%= if Map.get(post, :code_snippet) do %>
            <div class="mx-5 mb-5 rounded-xl overflow-hidden bg-base-900 shadow-inner">
              <div class="bg-base-800 px-4 py-1.5 flex items-center justify-between">
                <span class="text-[11px] font-black text-white/40 uppercase tracking-widest">
                  Code Preview
                </span>
                <.icon name="hero-clipboard" class="w-3.5 h-3.5 text-white/40" />
              </div>
              <pre class="p-4 text-[13px] text-white/90 font-mono overflow-x-auto"><code>{post.code_snippet}</code></pre>
            </div>
          <% end %>

          <div class="px-6 py-4 bg-base-200/30 border-t border-base-200 flex items-center gap-6">
            <button class="flex items-center gap-2 text-base-content/40 hover:text-primary transition-colors text-xs font-bold uppercase tracking-widest">
              <.icon name="hero-heart" class="w-4.5 h-4.5" />
              <span>React</span>
            </button>
            <button class="flex items-center gap-2 text-base-content/40 hover:text-primary transition-colors text-xs font-bold uppercase tracking-widest">
              <.icon name="hero-chat-bubble-left" class="w-4.5 h-4.5" />
              <span>Thread</span>
            </button>
            <button class="flex items-center gap-2 text-base-content/40 hover:text-primary transition-colors text-xs font-bold uppercase tracking-widest ml-auto">
              <.icon name="hero-share" class="w-4.5 h-4.5" />
            </button>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp render_channel_content(assigns) do
    ~H"""
    <div class="flex-1 flex flex-col items-center justify-center text-base-content/50 bg-base-100">
      <div class="w-20 h-20 bg-base-200 rounded-[28px] flex items-center justify-center mb-6 shadow-sm border border-base-300">
        <.icon name={get_channel_icon(@active_channel.type)} class="h-10 w-10 opacity-30" />
      </div>
      <h2 class="text-2xl font-black text-base-content mb-2 tracking-tighter uppercase">
        {@active_channel.name}
      </h2>
      <p class="text-sm italic font-medium">
        The <span class="text-primary font-bold">{@active_channel.type}</span>
        workspace module is synchronizing...
      </p>

      <div class="mt-8 flex gap-3">
        <div
          :for={i <- 1..3}
          class="h-1 w-8 bg-primary/20 rounded-full animate-pulse"
          style={"animation-delay: #{i * 0.2}s"}
        >
        </div>
      </div>
    </div>
    """
  end

  defp create_channel_modal(assigns) do
    ~H"""
    <div class="fixed inset-0 z-[100] flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-base-content/10 backdrop-blur-md" phx-click="close_modal"></div>
      <div class="bg-base-100 w-full max-w-lg rounded-[32px] shadow-[0_32px_128px_-16px_rgba(0,0,0,0.3)] border border-base-300 overflow-hidden relative animate-in fade-in zoom-in duration-300">
        <div class="p-8">
          <div class="flex items-center justify-between mb-8">
            <h2 class="text-3xl font-black text-base-content tracking-tighter uppercase leading-none">
              Create Channel
            </h2>
            <button
              phx-click="close_modal"
              class="text-base-content/40 hover:text-base-content transition-colors p-2 hover:bg-base-200 rounded-full"
            >
              <.icon name="hero-x-mark" class="w-6 h-6" />
            </button>
          </div>

          <.form for={@channel_form} phx-submit="save_channel" class="space-y-8">
            <div>
              <label class="block text-[11px] font-black text-base-content/40 uppercase tracking-[0.2em] mb-4">
                Channel Purpose
              </label>
              <div class="grid grid-cols-2 sm:grid-cols-3 gap-3">
                <%= for type <- [:general_chat, :project, :posts, :threads, :files, :hackathons] do %>
                  <label class={[
                    "flex flex-col items-center justify-center p-4 rounded-2xl border-2 cursor-pointer transition-all gap-3 hover:scale-[1.02]",
                    (to_string(@channel_form[:type].value) == to_string(type) &&
                       "border-primary bg-primary/5 shadow-inner") ||
                      "border-base-200 hover:bg-base-200/50"
                  ]}>
                    <input
                      type="radio"
                      name="type"
                      value={type}
                      checked={to_string(@channel_form[:type].value) == to_string(type)}
                      class="hidden"
                    />
                    <.icon
                      name={get_channel_icon(type)}
                      class={[
                        "h-6 w-6",
                        (to_string(@channel_form[:type].value) == to_string(type) && "text-primary") ||
                          "text-base-content/30"
                      ]}
                    />
                    <span class={[
                      "text-[10px] font-black uppercase tracking-widest",
                      (to_string(@channel_form[:type].value) == to_string(type) && "text-primary") ||
                        "text-base-content/60"
                    ]}>
                      {to_string(type) |> String.replace("_", " ")}
                    </span>
                  </label>
                <% end %>
              </div>
            </div>

            <div>
              <label class="block text-[11px] font-black text-base-content/40 uppercase tracking-[0.2em] mb-3">
                Channel Identity
              </label>
              <div class="relative group">
                <span class="absolute left-4 top-1/2 -translate-y-1/2 text-base-content/20 font-black text-xl group-focus-within:text-primary transition-colors">
                  #
                </span>
                <input
                  type="text"
                  name="name"
                  value={@channel_form[:name].value}
                  class="w-full bg-base-200 border-none rounded-2xl p-4 pl-10 text-base-content font-bold focus:ring-4 ring-primary/10 transition-all placeholder:text-base-content/20"
                  placeholder="epic-feature-branch"
                  required
                />
              </div>
            </div>

            <div class="flex items-center gap-4 pt-4">
              <div class="text-[12px] text-base-content/40 max-w-[200px] leading-tight italic">
                New channels are added to
                <span class="font-bold text-base-content/60 italic">
                  {@categories |> Enum.find(&(&1.id == @selected_category_id)) |> Map.get(:name)}
                </span>
              </div>
              <div class="flex-1"></div>
              <button
                type="submit"
                class="bg-primary text-primary-content font-black uppercase tracking-widest text-sm py-4 px-8 rounded-2xl transition-all shadow-xl shadow-primary/30 hover:shadow-primary/40 active:scale-95"
              >
                Finalize Creation
              </button>
            </div>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  defp create_server_modal(assigns) do
    ~H"""
    <div class="fixed inset-0 z-[100] flex items-center justify-center p-4">
      <div class="absolute inset-0 bg-base-content/10 backdrop-blur-md" phx-click="close_modal"></div>
      <div class="bg-base-100 w-full max-w-lg rounded-[32px] shadow-[0_32px_128px_-16px_rgba(0,0,0,0.3)] border border-base-300 overflow-hidden relative animate-in fade-in zoom-in duration-300">
        <div class="p-8 text-center">
          <h2 class="text-4xl font-black text-base-content tracking-tighter uppercase leading-none mb-4">
            New Hub
          </h2>
          <p class="text-base-content/60 text-sm mb-8">
            Create a space for your engineering team to collaborate and build.
          </p>

          <.form for={@server_form} phx-submit="save_server" class="space-y-6">
            <div class="flex justify-center mb-8">
              <div class="w-24 h-24 bg-base-200 rounded-[32px] border-4 border-dashed border-base-300 flex items-center justify-center text-base-content/20 hover:border-primary hover:text-primary transition-all cursor-pointer group">
                <.icon name="hero-plus" class="w-10 h-10 group-hover:scale-110 transition-transform" />
              </div>
            </div>

            <div class="text-left">
              <label class="block text-[11px] font-black text-base-content/40 uppercase tracking-[0.2em] mb-3 ml-1">
                Server Name
              </label>
              <input
                type="text"
                name="name"
                value={@server_form[:name].value}
                class="w-full bg-base-200 border-none rounded-2xl p-4 text-base-content font-bold focus:ring-4 ring-primary/10 transition-all placeholder:text-base-content/20"
                placeholder="Rocket Labs"
                required
              />
            </div>

            <button
              type="submit"
              class="w-full bg-base-content text-base-100 font-black uppercase tracking-widest text-sm py-4 rounded-2xl transition-all shadow-xl hover:bg-primary hover:text-primary-content active:scale-95"
            >
              Establish Server
            </button>
          </.form>
        </div>
      </div>
    </div>
    """
  end

  # Events

  @impl true
  def handle_event("open_server_form", _, socket) do
    {:noreply,
     socket
     |> assign(:modal, :create_server)
     |> assign(:server_form, to_form(%{"name" => ""}))}
  end

  @impl true
  def handle_event("open_create_channel", %{"category_id" => category_id}, socket) do
    {:noreply,
     socket
     |> assign(:modal, :create_channel)
     |> assign(:selected_category_id, category_id)
     |> assign(:channel_form, to_form(%{"name" => "", "type" => "general_chat"}))}
  end

  # Minimal default for parameterless call
  def handle_event("open_create_channel", _, socket) do
    category_id = List.first(socket.assigns.categories).id
    handle_event("open_create_channel", %{"category_id" => category_id}, socket)
  end

  @impl true
  def handle_event("close_modal", _, socket) do
    {:noreply, assign(socket, :modal, nil)}
  end

  @impl true
  def handle_event("save_server", %{"name" => name}, socket) do
    case Communities.create_server(%{"name" => name}, socket.assigns.current_user.id) do
      {:ok, server} ->
        {:noreply,
         socket
         |> assign(:modal, nil)
         |> push_navigate(to: ~p"/servers/#{server.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :server_form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("save_channel", %{"name" => name, "type" => type}, socket) do
    attrs = %{
      "name" => name,
      "type" => type,
      "category_id" => socket.assigns.selected_category_id,
      "server_id" => socket.assigns.server.id
    }

    case Communities.create_channel(attrs) do
      {:ok, channel} ->
        {:noreply,
         socket
         |> assign(:modal, nil)
         |> push_navigate(to: ~p"/servers/#{socket.assigns.server.id}/channels/#{channel.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :channel_form, to_form(changeset))}
    end
  end

  @impl true
  def handle_event("send_message", %{"content" => content}, socket) do
    if content != "" && socket.assigns.active_channel.type == :general_chat do
      Messaging.create_message(%{
        content: content,
        channel_id: socket.assigns.active_channel.id,
        user_id: socket.assigns.current_user.id
      })
    end

    {:noreply, assign(socket, :form, to_form(%{"content" => ""}))}
  end

  @impl true
  def handle_event("typing", %{"value" => _value}, socket) do
    if connected?(socket) do
      user = socket.assigns.current_user
      username = user.email |> String.split("@") |> List.first()
      
      Phoenix.PubSub.broadcast(
        EngHub.PubSub,
        "typing:#{socket.assigns.active_channel.id}",
        {:typing, %{id: user.id, username: username}}
      )
    end
    {:noreply, socket}
  end

  @impl true
  def handle_info({Communities, :channel_created, _channel}, socket) do
    {server, categories} = Communities.get_server_tree(socket.assigns.server.id)
    {:noreply, assign(socket, server: server, categories: categories)}
  end

  @impl true
  def handle_info({Messaging, :message_created, message}, socket) do
    # Only insert if it belongs to current active channel
    if to_string(message.channel_id) == to_string(socket.assigns.active_channel.id) do
      last_meta = socket.assigns.last_message_meta
      continuous? = 
        last_meta && 
        last_meta.user_id == message.user_id && 
        DateTime.diff(message.inserted_at, last_meta.inserted_at) < 300

      message = Map.put(message, :continuous?, continuous?)
      
      {:noreply, 
        socket 
        |> stream_insert(:messages, message)
        |> assign(last_message_meta: %{user_id: message.user_id, inserted_at: message.inserted_at})}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:typing, %{id: user_id, username: username}}, socket) do
    # Ignore self typing
    if user_id == socket.assigns.current_user.id do
      {:noreply, socket}
    else
      # Remove user after 3 seconds of inactivity
      Process.send_after(self(), {:stop_typing, user_id}, 3000)
      
      typing_users = Map.put(socket.assigns.typing_users, user_id, username)
      {:noreply, assign(socket, :typing_users, typing_users)}
    end
  end

  @impl true
  def handle_info({:stop_typing, user_id}, socket) do
    typing_users = Map.delete(socket.assigns.typing_users, user_id)
    {:noreply, assign(socket, :typing_users, typing_users)}
  end

  @impl true
  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"}, socket) do
    # Simple strategy: just re-fetch presence map or update local assign
    # For a refined experience, we'd use Presence.list/1 and merge
    online_users = EngHubWeb.Presence.list("server:#{socket.assigns.server.id}")
    {:noreply, assign(socket, :online_user_ids, Map.keys(online_users))}
  end
end

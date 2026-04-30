defmodule EngHubWeb.ChannelLive.Chat do
  use EngHubWeb, :live_view

  alias EngHub.Messaging
  alias EngHub.Repo

  @impl true
  def mount(_params, %{"channel_id" => channel_id, "current_user_id" => current_user_id}, socket) do
    {:ok, user} = EngHub.Identity.get(current_user_id)
    channel = EngHub.Messaging.get_channel!(channel_id)

    if connected?(socket) do
      Messaging.subscribe(to_string(channel.id))
      Phoenix.PubSub.subscribe(EngHub.PubSub, "typing:#{channel.id}")
    end

    messages =
      Messaging.list_messages_by_channel(channel.id)
      |> Enum.map_reduce(nil, fn msg, last_msg ->
        continuous? =
          last_msg && last_msg.user_id == msg.user_id &&
            DateTime.diff(msg.inserted_at, last_msg.inserted_at) < 300 &&
            Date.diff(
              DateTime.to_date(msg.inserted_at),
              DateTime.to_date(last_msg.inserted_at)
            ) == 0

        new_day? =
          is_nil(last_msg) ||
            Date.diff(
              DateTime.to_date(msg.inserted_at),
              DateTime.to_date(last_msg.inserted_at)
            ) != 0

        {msg
         |> Map.put(:continuous?, continuous? && !new_day?)
         |> Map.put(:new_day?, new_day?), msg}
      end)
      |> elem(0)

    socket =
      socket
      |> assign(:current_user, user)
      |> assign(:active_channel, channel)
      |> stream(:messages, messages, reset: true)
      |> assign(:form, to_form(%{"content" => ""}))
      |> assign(:typing_users, %{})
      |> assign(:replying_to, nil)
      |> assign(:editing_id, nil)
      |> assign(:edit_form, nil)
      |> assign(
        :last_message_meta,
        if Enum.empty?(messages) do
          nil
        else
          last = List.last(messages)
          %{user_id: last.user_id, inserted_at: last.inserted_at}
        end
      )

    {:ok, socket, layout: false}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex-1 flex flex-col min-w-0 bg-base-100 overflow-hidden relative h-full">
      <!-- Channel Header -->
      <div class="h-12 shrink-0 flex items-center px-3 glass-header z-30 shadow-sm border-b border-black/10">
        <div class="flex items-center gap-2 px-1 py-0.5 rounded-md hover:bg-white/[0.03] transition-colors cursor-pointer group">
          <.icon
            name="hero-hashtag"
            class="w-6 h-6 text-white/30 group-hover:text-white/50 transition-colors"
          />
          <h2 class="font-bold text-[15px] text-white tracking-tight">{@active_channel.name}</h2>
        </div>
        <div class="mx-3 h-6 w-[1px] bg-white/5"></div>
        <div class="text-[13px] text-white/40 font-medium truncate italic max-w-md">
          {@active_channel.topic || "Real-time communication and team discussions."}
        </div>

        <div class="ml-auto flex items-center gap-3">
           <button class="p-1 px-2 text-white/40 hover:text-white transition-colors relative group">
             <.icon name="hero-bell" class="w-5 h-5" />
             <span class="premium-tooltip">Notifications</span>
           </button>
        </div>
      </div>

      <!-- Reply Overlay -->
      <div
        :if={@replying_to}
        class="absolute bottom-[60px] left-4 right-4 bg-base-200 border border-white/5 rounded-t-lg p-2 flex items-center gap-3 z-30 animate-in slide-in-from-bottom-2 duration-200"
      >
        <div class="w-1 h-6 bg-primary rounded-full"></div>
        <div class="flex-1 min-w-0">
          <span class="text-[11px] font-black text-white/40 uppercase tracking-widest block">
            Replying to {@replying_to.user.email |> String.split("@") |> List.first()}
          </span>
          <span class="text-xs text-white/60 truncate block italic">
            {@replying_to.content}
          </span>
        </div>
        <button phx-click="cancel_reply" class="p-1 hover:bg-white/5 rounded-full text-white/40 hover:text-white transition-all">
          <.icon name="hero-x-mark" class="w-4 h-4" />
        </button>
      </div>

      <div
        class="flex-1 overflow-y-auto custom-scrollbar pt-0"
        id={"chat-messages-container-#{@active_channel.id}"}
        phx-hook="SmartScroll"
        data-at-bottom="true"
      >
        <div id="chat-messages-skeleton" class="only:flex hidden h-full items-center justify-center p-12">
          <.chat_skeleton />
        </div>
        
        <!-- Channel Welcome State (Compact) -->
        <div id="chat-welcome-state" class="px-4 pt-8 pb-3 border-b border-white/[0.04]">
          <div class="w-10 h-10 rounded-[12px] bg-white/5 flex items-center justify-center mb-2">
            <.icon name="hero-hashtag" class="w-6 h-6 text-white/30" />
          </div>
          <h1 class="text-xl font-black text-white tracking-tight mb-0.5">
            #{@active_channel.name}
          </h1>
          <p class="text-white/30 text-[13px] leading-snug">
            Start of <span class="text-white/50 font-semibold">##{@active_channel.name}</span> channel.
          </p>
        </div>

        <div id={"chat-messages-#{@active_channel.id}"} phx-update="stream">
          <div
            :for={{dom_id, message} <- @streams.messages}
            id={dom_id}
            class={[
              "group relative flex px-4 hover:bg-white/[0.02] transition-colors",
              if(Map.get(message, :continuous?), do: "pt-0.5 pb-0", else: "pt-2 pb-0")
            ]}
          >
            <%= if Map.get(message, :new_day?) do %>
              <div class="date-separator w-full">
                <span>{format_date(message.inserted_at)}</span>
              </div>
            <% end %>

            <div class="absolute right-3 top-0 -translate-y-1/2 invisible group-hover:visible flex items-center message-action-bar rounded-md overflow-hidden z-30 divide-x divide-white/5">
              <div class="flex items-center">
                <%= for emoji <- ["❤️", "🔥", "👍"] do %>
                  <button phx-click="toggle_reaction" phx-value-id={message.id} phx-value-emoji={emoji} class="px-1.5 py-1 text-white/50 hover:text-white transition-all"><span class="text-sm">{emoji}</span></button>
                <% end %>
              </div>
              <div class="flex items-center">
                <button phx-click="set_reply" phx-value-id={message.id} class="px-1.5 py-1 text-white/40 hover:text-white transition-all"><.icon name="hero-arrow-uturn-left" class="w-4 h-4" /></button>
                <button phx-click="edit_message" phx-value-id={message.id} class="px-1.5 py-1 text-white/40 hover:text-white transition-all"><.icon name="hero-pencil" class="w-4 h-4" /></button>
                <button phx-click="delete_message" phx-value-id={message.id} class="px-1.5 py-1 text-white/40 hover:text-error transition-all"><.icon name="hero-trash" class="w-4 h-4" /></button>
              </div>
            </div>

            <%= if !Map.get(message, :continuous?) do %>
              <div class="w-8 h-8 shrink-0 rounded-[8px] bg-base-300 flex items-center justify-center text-white/50 font-bold text-[13px] mr-2 mt-0.5 cursor-pointer select-none border border-white/5 hover:border-white/10 transition-colors">
                {String.at(message.user.email, 0) |> String.upcase()}
              </div>
            <% else %>
              <div class="w-8 mr-2 shrink-0 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                <span class="text-[9px] text-white/20 tabular-nums">
                  {Calendar.strftime(message.inserted_at, "%H:%M")}
                </span>
              </div>
            <% end %>
            
            <div class="flex-1 min-w-0">
               <%= if !Map.get(message, :continuous?) do %>
                 <%= if message.parent do %>
                   <div class="flex items-center gap-1.5 mb-0.5 opacity-60">
                     <div class="w-1 h-1 rounded-full bg-white/20"></div>
                     <span class="text-[11px] text-white/50 font-semibold truncate">@{message.parent.user.email |> String.split("@") |> List.first()}</span>
                     <span class="text-[11px] text-white/20 truncate italic">{message.parent.content}</span>
                   </div>
                 <% end %>
                 <div class="flex items-baseline gap-2 leading-none mb-[3px]">
                    <span class="text-[14px] font-bold text-white/90 leading-none">{message.user.email |> String.split("@") |> List.first()}</span>
                    <span class="text-[10px] text-white/20 tabular-nums font-medium">{Calendar.strftime(message.inserted_at, "%I:%M %p")}</span>
                 </div>
               <% end %>

               <%= if @editing_id == to_string(message.id) do %>
                  <.form for={@edit_form} phx-submit="save_edit" class="mt-1">
                    <div class="bg-black/20 border border-white/10 rounded-md overflow-hidden flex">
                      <input type="text" name="content" value={@edit_form[:content].value} class="w-full bg-transparent border-none focus:ring-0 text-[14px] px-2 py-1.5 text-white/90" autofocus />
                      <div class="px-2 py-1 bg-black/20 flex gap-2">
                        <button type="submit" class="text-[10px] font-black uppercase tracking-widest text-primary hover:text-white">Save</button>
                        <button type="button" phx-click="cancel_edit" class="text-[10px] font-black uppercase tracking-widest text-white/20 hover:text-white">Cancel</button>
                      </div>
                    </div>
                  </.form>
               <% else %>
                  <p class="text-white/80 text-[14px] leading-[1.4] break-words">{message.content}</p>
               <% end %>

               <.message_reactions message={message} current_user={@current_user} />
            </div>
          </div>
          <div id={"chat-messages-bottom-padding-#{@active_channel.id}"} class="h-4"></div>
        </div>
      </div>
      
      <!-- Input Bar -->
      <div class="px-4 pb-3 pt-1.5 shrink-0 bg-base-100 border-t border-white/[0.04] z-20">
        <div class="h-4 flex items-center mb-1">
          <%= if map_size(@typing_users) > 0 do %>
            <div class="flex items-center gap-2">
              <span class="text-[11px] font-bold text-white/25 italic">Someone is typing...</span>
            </div>
          <% end %>
        </div>

        <.form for={@form} phx-submit="send_message" phx-change="typing" class="bg-base-300/80 border border-white/[0.06] rounded-lg px-3 flex items-center gap-2 focus-within:border-primary/30 focus-within:bg-base-300 transition-all h-[40px]">
          <button type="button" class="text-white/20 hover:text-white/60 transition-all shrink-0">
            <.icon name="hero-plus-circle-solid" class="w-5 h-5" />
          </button>
          <input type="text" name="content" value={@form[:content].value} class="flex-1 bg-transparent border-none focus:ring-0 text-[14px] text-white/80 placeholder:text-white/15" placeholder={"Message ##{@active_channel.name}"} autocomplete="off" phx-focus="typing_started" />
        </.form>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("send_message", %{"content" => content}, socket) do
    if String.trim(content) != "" do
      Messaging.create_message(%{
        content: content,
        channel_id: socket.assigns.active_channel.id,
        user_id: socket.assigns.current_user.id,
        parent_id: socket.assigns.replying_to && socket.assigns.replying_to.id
      })
    end

    {:noreply, assign(socket, form: to_form(%{"content" => ""}), replying_to: nil)}
  end

  @impl true
  def handle_event("edit_message", %{"id" => id}, socket) do
    message = Messaging.get_message!(id)
    {:noreply, assign(socket, editing_id: id, edit_form: to_form(%{"content" => message.content}))}
  end

  @impl true
  def handle_event("save_edit", %{"content" => content}, socket) do
    message = Messaging.get_message!(socket.assigns.editing_id)
    case Messaging.update_message(message, %{content: content}) do
      {:ok, _} -> {:noreply, assign(socket, editing_id: nil, edit_form: nil)}
      {:error, changeset} -> {:noreply, assign(socket, edit_form: to_form(changeset))}
    end
  end

  @impl true
  def handle_event("cancel_edit", _, socket) do
    {:noreply, assign(socket, editing_id: nil, edit_form: nil)}
  end

  @impl true
  def handle_event("delete_message", %{"id" => id}, socket) do
    message = Messaging.get_message!(id)
    Messaging.delete_message(message)
    {:noreply, socket}
  end

  @impl true
  def handle_event("set_reply", %{"id" => id}, socket) do
    message = Messaging.get_message!(id) |> Repo.preload(:user)
    {:noreply, assign(socket, replying_to: message)}
  end

  @impl true
  def handle_event("cancel_reply", _, socket) do
    {:noreply, assign(socket, replying_to: nil)}
  end

  @impl true
  def handle_event("toggle_reaction", %{"id" => id, "emoji" => emoji}, socket) do
    user_id = socket.assigns.current_user.id
    message = Messaging.get_message!(id) |> Repo.preload(:reactions)

    if Enum.find(message.reactions, &(&1.user_id == user_id and &1.emoji == emoji)) do
      Messaging.delete_reaction(id, user_id, emoji)
    else
      Messaging.create_reaction(%{message_id: id, user_id: user_id, emoji: emoji})
    end

    {:noreply, socket}
  end

  @impl true
  def handle_event("typing_started", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("typing", %{"content" => content}, socket) do
    if connected?(socket) and String.trim(content) != "" do
      user = socket.assigns.current_user
      Phoenix.PubSub.broadcast(
        EngHub.PubSub,
        "typing:#{socket.assigns.active_channel.id}",
        {:typing, {user.id, user.email |> String.split("@") |> List.first()}}
      )
    end
    {:noreply, socket}
  end

  def handle_event("typing", _, socket), do: {:noreply, socket}

  # --- PubSub Handlers ---

  @impl true
  def handle_info({Messaging, :message_created, message}, socket) do
    if to_string(message.channel_id) == to_string(socket.assigns.active_channel.id) do
      last_meta = socket.assigns.last_message_meta

      continuous? =
        last_meta && last_meta.user_id == message.user_id &&
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
  def handle_info({Messaging, :message_updated, message}, socket) do
    if to_string(message.channel_id) == to_string(socket.assigns.active_channel.id) do
      {:noreply, stream_insert(socket, :messages, message)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({Messaging, :message_deleted, message}, socket) do
    {:noreply, stream_delete(socket, :messages, message)}
  end

  @impl true
  def handle_info({:typing, {user_id, display_name}}, socket) do
    if user_id == socket.assigns.current_user.id do
      {:noreply, socket}
    else
      Process.send_after(self(), {:stop_typing, user_id}, 3000)
      {:noreply, assign(socket, typing_users: Map.put(socket.assigns.typing_users, user_id, display_name))}
    end
  end

  @impl true
  def handle_info({:stop_typing, user_id}, socket) do
    {:noreply, assign(socket, typing_users: Map.delete(socket.assigns.typing_users, user_id))}
  end

  defp format_date(date) do
    today = Date.utc_today()
    date_val = DateTime.to_date(date)

    cond do
      date_val == today -> "Today"
      Date.diff(today, date_val) == 1 -> "Yesterday"
      true -> Calendar.strftime(date, "%B %d, %Y")
    end
  end

  def message_reactions(assigns) do
    ~H"""
    <%= if not Enum.empty?(@message.reactions) do %>
      <div class="flex flex-wrap gap-1 mt-1.5">
        <%= for {emoji, reactions} <- Enum.group_by(@message.reactions, & &1.emoji) do %>
          <% user_reacted = Enum.any?(reactions, &(&1.user_id == @current_user.id)) %>
          <button
            phx-click="toggle_reaction"
            phx-value-id={@message.id}
            phx-value-emoji={emoji}
            class={["px-1.5 py-0.5 rounded flex items-center gap-1 text-[11px] font-bold transition-all select-none border", 
              user_reacted && "bg-primary/20 border-primary/40 text-primary-content",
              !user_reacted && "bg-base-300 border-base-content/10 text-base-content/60 hover:bg-base-200"
            ]}
          >
            <span class="text-[13px] translate-y-[-1px]">{emoji}</span>
            <span>{length(reactions)}</span>
          </button>
        <% end %>
      </div>
    <% end %>
    """
  end

  # Skeleton provided by SkeletonComponents
end

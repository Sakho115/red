defmodule EngHubWeb.MemberComponents do
  use Phoenix.Component
  import EngHubWeb.CoreComponents
  import EngHubWeb.SkeletonComponents

  @doc """
  Renders the member list sidebar (Pane 4).
  """
  def member_sidebar(assigns) do
    online_user_ids = Enum.map(assigns.online_user_ids, &to_string/1)

    # 1. Identify members as online/offline
    members =
      Enum.map(assigns.members, fn m ->
        online? = to_string(m.user_id) in online_user_ids
        # Find highest priority hoisted role
        hoisted_role =
          m.roles
          |> Enum.filter(& &1.hoist)
          |> Enum.sort_by(& &1.position)
          |> List.first()

        Map.merge(m, %{online?: online?, hoisted_role: hoisted_role})
      end)

    # 2. Group by hoisted role (only for online members)
    {online_members, offline_members} = Enum.split_with(members, & &1.online?)

    grouped_online =
      online_members
      |> Enum.group_by(& &1.hoisted_role)
      # Sort groups by role position
      |> Enum.sort_by(fn {role, _} -> (role && role.position) || 999_999 end)

    assigns =
      assigns
      |> assign(:grouped_online, grouped_online)
      |> assign(:offline_members, offline_members)

    ~H"""
    <aside class="hidden xl:flex w-60 shrink-0 flex-col select-none glass-sidebar border-l border-white/5 z-30">
      <div class="flex-1 overflow-y-auto px-2 py-2 space-y-4 custom-scrollbar">
        <%= if Enum.empty?(@members) do %>
          <.member_list_skeleton />
        <% else %>
          <!-- Online Groups -->
          <%= for {role, members} <- @grouped_online do %>
            <div class="space-y-0.5">
              <div class="text-[11px] font-bold text-white/20 uppercase tracking-[0.05em] px-2 pt-3 pb-1 flex items-center gap-2">
                {if(role, do: role.name, else: "Online")} — {length(members)}
              </div>

              <%= for member <- members do %>
                <.member_item member={member} role={role} />
              <% end %>
            </div>
          <% end %>
          
    <!-- Offline Group -->
          <%= if length(@offline_members) > 0 do %>
            <div class="space-y-0.5 opacity-40 hover:opacity-100 transition-opacity">
              <div class="text-[11px] font-bold text-white/20 uppercase tracking-[0.05em] px-2 pt-3 pb-1">
                Offline — {length(@offline_members)}
              </div>
              <%= for member <- @offline_members do %>
                <.member_item member={member} role={nil} />
              <% end %>
            </div>
          <% end %>
        <% end %>
      </div>
      
    <!-- Footer Info (Premium Branding) -->
      <div class="p-3 bg-black/10 border-t border-white/5 mx-2 my-2 rounded-xl mb-4">
        <div class="bg-primary/5 rounded-lg p-2 border border-primary/10">
          <div class="flex items-center gap-2 mb-1.5">
            <.icon name="hero-sparkles-solid" class="w-3.5 h-3.5 text-primary" />
            <span class="text-[9px] font-black text-white/40 uppercase tracking-[0.15em]">
              Security Protocol
            </span>
          </div>
          <div class="h-1 bg-white/5 rounded-full overflow-hidden">
            <div class="h-full bg-primary w-[92%] shadow-[0_0_8px_rgba(var(--color-primary),0.5)]">
            </div>
          </div>
        </div>
      </div>
    </aside>
    """
  end

  defp member_item(assigns) do
    ~H"""
    <div
      phx-click="open_profile"
      phx-value-id={@member.user_id}
      class="flex items-center gap-2 px-2 py-[3px] rounded-md hover:bg-white/[0.05] cursor-pointer group transition-all relative active-scale"
    >
      <div class="relative shrink-0">
        <div
          class="w-8 h-8 rounded-full flex items-center justify-center font-bold text-[13px] transition-all shadow-sm bg-base-300 text-white/40 border border-white/5 group-hover:border-white/10"
          style={
            if(@role && @role.color,
              do:
                "background-color: #{@role.color}15; border-color: #{@role.color}30; color: #{@role.color}"
            )
          }
        >
          {String.at(@member.user.email, 0) |> String.upcase()}
        </div>
        <%= if @member.online? do %>
          <div class="absolute bottom-[-1px] right-[-1px] w-2.5 h-2.5 bg-success rounded-full border-[2px] border-base-200">
          </div>
        <% end %>
      </div>

      <div class="flex-1 min-w-0">
        <div
          class="text-[14px] font-medium truncate leading-none transition-colors text-white/40 group-hover:text-white/90"
          style={if(@role && @role.color, do: "color: #{@role.color}")}
        >
          {@member.user.email |> String.split("@") |> List.first()}
        </div>
        <div class="text-[11px] text-white/10 font-bold truncate tracking-tight flex items-center gap-1 mt-0.5 leading-none">
          {(@role && @role.name) || @member.role |> String.capitalize()}
        </div>
      </div>
    </div>
    """
  end
end

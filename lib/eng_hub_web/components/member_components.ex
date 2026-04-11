defmodule EngHubWeb.MemberComponents do
  use Phoenix.Component
  import EngHubWeb.CoreComponents

  @doc """
  Renders the member list sidebar (Pane 4).
  """
  def member_sidebar(%{members: members, online_user_ids: online_user_ids} = assigns) do
    # Sort members: Online first, then by role (owner -> admin -> member), then by email
    sorted_members = 
      members
      |> Enum.sort_by(fn m -> 
        online? = to_string(m.user_id) in Enum.map(online_user_ids, &to_string/1)
        role_rank = case m.role do "owner" -> 0; "admin" -> 1; "member" -> 2; _ -> 3 end
        {!online?, role_rank, m.user.email}
      end)
      
    assigns = assign(assigns, :sorted_members, sorted_members)

    ~H"""
    <aside class="hidden xl:flex w-60 flex-shrink-0 flex-col select-none glass-sidebar border-l border-white/5 z-30">
      <div class="flex-1 overflow-y-auto px-2 py-3 space-y-6 custom-scrollbar">
        <div class="space-y-0.5">
          <div class="text-[11px] font-black text-white/30 uppercase tracking-[0.1em] px-2 py-2 flex items-center gap-2">
            Members — {length(@members)}
          </div>
          
          <%= for member <- @sorted_members do %>
            <% 
              online? = to_string(member.user_id) in Enum.map(@online_user_ids, &to_string/1)
            %>
            <div class={[
              "flex items-center gap-2.5 px-2 py-1.5 rounded-md hover:bg-white/5 cursor-pointer group transition-all relative",
              !online? && "opacity-40 hover:opacity-100"
            ]}>
              <div class="relative">
                <div class={[
                  "w-8 h-8 rounded-[12px] flex items-center justify-center font-black text-xs transition-all shadow-inner shadow-white/5",
                  if(member.role == "owner", do: "bg-warning/20 text-warning border border-warning/20", else: "bg-primary/20 text-primary border border-primary/20"),
                  "group-hover:rounded-[10px]"
                ]}>
                  {String.at(member.user.email, 0) |> String.upcase()}
                </div>
                
                <!-- Online Status Dot -->
                <%= if online? do %>
                  <div class="absolute bottom-[-1px] right-[-1px] w-2.5 h-2.5 bg-success rounded-full border-2 border-base-200"></div>
                <% end %>
              </div>
              
              <div class="flex-1 min-w-0">
                <div class={[
                  "text-[14px] font-bold truncate leading-tight transition-colors",
                  if(member.role == "owner", do: "text-warning", else: "text-white/60 group-hover:text-white")
                ]}>
                  {member.user.email |> String.split("@") |> List.first()}
                </div>
                <div class="text-[11px] text-white/20 font-bold truncate tracking-tight flex items-center gap-1">
                  <%= if member.role == "owner" do %>
                    <.icon name="hero-bolt-solid" class="w-3 h-3 text-warning" />
                  <% end %>
                  {member.role |> String.capitalize()}
                </div>
              </div>
            </div>
          <% end %>
        </div>
      </div>

      <!-- Footer Info -->
      <div class="p-3 bg-black/10 border-t border-white/5">
        <div class="bg-primary/5 rounded-lg p-2 border border-primary/10">
          <div class="flex items-center gap-2 mb-1">
            <.icon name="hero-shield-check" class="w-4 h-4 text-primary" />
            <span class="text-[11px] font-black text-white/50 uppercase tracking-tighter">Security Grade</span>
          </div>
          <div class="h-1.5 bg-white/5 rounded-full overflow-hidden">
            <div class="h-full bg-primary w-[85%]"></div>
          </div>
        </div>
      </div>
    </aside>
    """
  end
end

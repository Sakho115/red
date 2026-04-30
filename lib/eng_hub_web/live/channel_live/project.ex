defmodule EngHubWeb.ChannelLive.Project do
  use EngHubWeb, :live_view

  alias EngHub.Projects
  alias EngHub.Communities

  @impl true
  def mount(_params, %{"channel_id" => channel_id}, socket) do
    channel = EngHub.Messaging.get_channel!(channel_id)
    project = if channel.project_id, do: Projects.get_project!(channel.project_id), else: nil

    socket =
      socket
      |> assign(:active_channel, channel)
      |> assign(:project, project)

    {:ok, socket, layout: false}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="flex-1 overflow-y-auto bg-base-100 p-8 custom-scrollbar h-full">
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
                   <div class="text-base-content/40 italic">Activity stream coming soon.</div>
                </div>
              </div>
            </div>

            <div class="space-y-6">
              <div class="bg-gradient-to-br from-primary/10 to-secondary/10 border border-primary/20 p-6 rounded-2xl">
                <h3 class="text-base-content font-black text-xs uppercase tracking-widest mb-4">
                  Contributors
                </h3>
                <div class="flex flex-wrap gap-2">
                  <div class="text-base-content/40 text-sm">No contributors yet.</div>
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
        <div class="flex-1 flex flex-col items-center justify-center h-full text-center py-20">
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
end

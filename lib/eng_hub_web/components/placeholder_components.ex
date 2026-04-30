defmodule EngHubWeb.PlaceholderComponents do
  use Phoenix.Component
  import EngHubWeb.CoreComponents
  import EngHubWeb.SkeletonComponents

  @doc """
  Renders a high-fidelity chat view placeholder.
  """
  attr :title, :string, required: true
  attr :subtitle, :string, default: nil
  attr :icon, :string, default: "hero-hashtag"

  def chat_placeholder(assigns) do
    ~H"""
    <div class="flex-1 flex flex-col h-full overflow-hidden bg-base-100">
      <header class="h-12 px-4 flex items-center glass-header shrink-0 z-20">
        <div class="flex items-center gap-2 mr-4">
          <.icon name={@icon} class="h-5 w-5 text-white/30 shrink-0" />
          <h2 class="font-bold text-[15px] text-white/90">{@title}</h2>
        </div>
        <div :if={@subtitle} class="w-[1px] h-6 bg-white/5 mx-2"></div>
        <div :if={@subtitle} class="text-[13px] text-white/40 font-medium truncate italic max-w-md">
          {@subtitle}
        </div>
      </header>

      <div class="flex-1 overflow-y-auto custom-scrollbar p-4 space-y-8">
        <div class="max-w-4xl mx-auto space-y-12 py-8">
          <div class="space-y-4">
            <div class="w-16 h-16 rounded-[24px] bg-white/5 flex items-center justify-center mb-6">
              <.icon name={@icon} class="w-8 h-8 text-white/20" />
            </div>
            <h1 class="text-3xl font-black text-white tracking-tighter uppercase italic">
              Welcome to {@title}
            </h1>
            <p class="text-white/40 text-[15px] font-medium leading-relaxed max-w-lg">
              This space is currently under construction. Soon, you will be able to collaborate, share insights, and manage engineering workflows here.
            </p>
          </div>

          <div class="space-y-6">
            <h3 class="text-[11px] font-black text-white/20 uppercase tracking-[0.2em]">
              Recent Activity
            </h3>
            <.chat_skeleton />
          </div>
        </div>
      </div>

      <div class="px-4 pb-6 pt-2 shrink-0 glass-surface mt-[-1px] z-20">
        <div class="bg-base-300 border border-white/5 rounded-xl px-4 flex items-center gap-3 shadow-xl h-11 opacity-50 cursor-not-allowed">
          <div class="flex-1 text-[15px] text-white/10 font-medium italic">
            Messaging is disabled in this preview...
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a high-fidelity list/discovery view placeholder.
  """
  attr :title, :string, required: true
  attr :type, :string, values: ~w(friends discovery grid), default: "friends"
  attr :opacity, :string, default: "1.0"

  def list_placeholder(assigns) do
    ~H"""
    <div class="flex-1 flex flex-col h-full bg-base-100 overflow-hidden" style={"opacity: #{@opacity}"}>
      <header class="h-12 px-4 flex items-center glass-header shrink-0 z-20">
        <h2 class="font-bold text-[15px] text-white/90">{@title}</h2>
      </header>

      <div class="flex-1 overflow-y-auto custom-scrollbar p-6">
        <div class="max-w-6xl mx-auto">
          <div class="flex items-center justify-between mb-8 pb-4 border-b border-white/5">
            <div class="text-[11px] font-black text-white/20 uppercase tracking-[0.2em]">
              {@title} Content
            </div>
            <div class="flex gap-2">
              <div class="h-8 w-32 bg-white/5 rounded-lg shimmer"></div>
              <div class="h-8 w-8 bg-white/5 rounded-lg shimmer"></div>
            </div>
          </div>

          <%= case @type do %>
            <% "grid" -> %>
              <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
                <%= for _ <- 1..9 do %>
                  <div class="glass-surface p-4 rounded-2xl border border-white/5 hover:border-white/10 transition-all group cursor-pointer">
                    <div class="h-32 bg-base-300 rounded-xl mb-4 shimmer"></div>
                    <div class="h-4 bg-white/10 rounded w-3/4 mb-2 shimmer"></div>
                    <div class="h-3 bg-white/5 rounded w-1/2 shimmer"></div>
                  </div>
                <% end %>
              </div>
            <% "friends" -> %>
              <.member_list_skeleton />
            <% _ -> %>
              <div class="space-y-4">
                <%= for _ <- 1..10 do %>
                  <div class="h-16 glass-surface rounded-xl border border-white/5 flex items-center px-4 gap-4 shimmer opacity-40">
                    <div class="w-10 h-10 rounded-full bg-white/5 shrink-0"></div>
                    <div class="flex-1 space-y-2">
                      <div class="h-3 bg-white/10 rounded w-1/4"></div>
                      <div class="h-2 bg-white/5 rounded w-1/2"></div>
                    </div>
                  </div>
                <% end %>
              </div>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a standardized settings content area.
  """
  attr :title, :string, required: true
  attr :description, :string, default: nil

  def settings_placeholder(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto py-16 px-10 animate-in fade-in slide-in-from-right-4 duration-500">
      <div class="mb-10">
        <h1 class="text-2xl font-black text-white tracking-tight mb-2 uppercase italic">
          {@title}
        </h1>
        <p :if={@description} class="text-white/40 text-[15px] font-medium leading-relaxed">
          {@description}
        </p>
      </div>

      <div class="space-y-12">
        <div class="space-y-6">
          <div class="h-px bg-white/5 w-full"></div>
          <div class="grid grid-cols-1 gap-8">
            <%= for _ <- 1..3 do %>
              <div class="space-y-3 opacity-50">
                <div class="h-3 bg-white/20 rounded w-1/4 shimmer"></div>
                <div class="h-12 bg-base-300 border border-white/5 rounded-xl shimmer"></div>
                <div class="h-2 bg-white/5 rounded w-1/2"></div>
              </div>
            <% end %>
          </div>
        </div>

        <div class="p-6 rounded-2xl bg-primary/5 border border-primary/20 flex items-center justify-between group">
          <div class="space-y-1">
            <h4 class="text-white font-bold text-sm">Experimental Feature</h4>
            <p class="text-[12px] text-white/40">Enable this at your own risk. It might be unstable.</p>
          </div>
          <div class="w-12 h-6 bg-white/10 rounded-full relative p-1 cursor-pointer">
            <div class="w-4 h-4 bg-white/30 rounded-full"></div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end

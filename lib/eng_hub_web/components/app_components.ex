defmodule EngHubWeb.AppComponents do
  use Phoenix.Component

  import EngHubWeb.CoreComponents
  import Phoenix.LiveView.Helpers, warn: false

  @doc """
  Renders the slide-out panel system (e.g. for User Profiles, Search, threads).
  """
  def dynamic_panel(assigns) do
    ~H"""
    <div
      class="absolute top-0 right-0 bottom-0 w-80 bg-base-200 shadow-2xl z-40 border-l border-white/5 transform transition-transform translate-x-0 overflow-y-auto"
    >
      <div class="h-12 border-b border-white/5 flex items-center justify-between px-4 bg-base-300">
        <span class="font-bold text-[13px] uppercase tracking-widest text-white/50">
          <%= case @panel do %>
            <% %{type: :search} -> %> Search
            <% %{type: :user_profile} -> %> User Profile
            <% %{type: :thread} -> %> Active Thread
            <% _ -> %> Panel
          <% end %>
        </span>
        <button phx-click="close_panel" class="text-white/40 hover:text-white transition-colors">
          <.icon name="hero-x-mark" class="w-5 h-5" />
        </button>
      </div>
      
      <div class="p-4">
        <!-- Render specific panel logic here -->
        <p class="text-white/40 italic text-sm">Showing panel: {@panel.type}</p>
      </div>
    </div>
    """
  end

  @doc """
  Renders the global application modal framework.
  """
  def dynamic_modal(assigns) do
    ~H"""
    <div class="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm">
      <div class="bg-base-100 rounded-xl shadow-2xl overflow-hidden w-full max-w-md animate-in fade-in zoom-in-95 duration-200 relative border border-white/10">
        <div class="h-12 bg-base-200 border-b border-white/5 flex items-center justify-between px-4">
           <span class="font-bold">{@active_modal}</span>
           <button phx-click="close_modal" class="text-white/40 hover:text-white transition-colors">
              <.icon name="hero-x-mark" class="w-5 h-5" />
           </button>
        </div>
        <div class="p-4">
           <!-- Dynamic modal content goes here -->
           Placeholder for {@active_modal}
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders the global unified settings tab system over the app shell.
  """
  def settings_overlay(assigns) do
    ~H"""
    <div class="fixed inset-0 z-50 bg-base-100 flex shadow-2xl animate-in fade-in duration-200">
      <div class="w-1/3 bg-base-200 flex justify-end py-16 pr-6 border-r border-white/5">
         <nav class="flex flex-col gap-1 w-48">
            <h3 class="text-[11px] font-black uppercase text-white/30 tracking-widest px-2 mb-2">User Settings</h3>
            <.link patch="?settings=my_account" class={"px-2 py-1.5 rounded-md text-[14px] font-medium #{if @active_tab == "my_account", do: "bg-white/10 text-white", else: "text-white/40 hover:bg-white/5 hover:text-white"}"}>My Account</.link>
            <.link patch="?settings=profile" class={"px-2 py-1.5 rounded-md text-[14px] font-medium #{if @active_tab == "profile", do: "bg-white/10 text-white", else: "text-white/40 hover:bg-white/5 hover:text-white"}"}>Profiles</.link>
         </nav>
      </div>
      <div class="flex-1 py-16 pl-10 pr-40 relative overflow-y-auto">
         <button phx-click="close_settings" class="absolute top-10 right-10 flex flex-col items-center gap-1 group">
           <div class="w-10 h-10 rounded-full border border-white/10 flex items-center justify-center text-white/40 group-hover:bg-white/5 group-hover:text-white transition-all">
             <.icon name="hero-x-mark" class="w-5 h-5 group-active:scale-90 transition-transform" />
           </div>
           <span class="text-[10px] font-bold text-white/20 group-hover:text-white/50 tracking-widest uppercase">ESC</span>
         </button>

         <div class="max-w-2xl">
           <h2 class="text-2xl font-black mb-8 text-white tracking-tight uppercase"><%= @active_tab |> String.replace("_", " ") %></h2>
           <p class="text-white/40">Settings panel configured to avoid full page reloads.</p>
         </div>
      </div>
    </div>
    """
  end
end

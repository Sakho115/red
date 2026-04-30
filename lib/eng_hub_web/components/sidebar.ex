defmodule EngHubWeb.Sidebar do
  use EngHubWeb, :html

  @doc """
  Renders the global navigation sidebar.
  """
  attr :current_user, :map, required: true
  attr :active_tab, :atom, default: :home

  def render(assigns) do
    ~H"""
    <nav class="hidden md:flex w-64 shrink-0 bg-base-200 border-r border-base-300 flex-col h-full overflow-y-auto">
      <div class="p-4 flex items-center gap-2 border-b border-base-300">
        <.icon name="hero-cube-transparent" class="w-8 h-8 text-primary" />
        <span class="font-bold text-lg tracking-tight">EngHub</span>
      </div>

      <div class="flex-1 py-4 flex flex-col gap-1 px-3">
        <.nav_link href={~p"/"} icon="hero-home" active={@active_tab == :home}>
          Home
        </.nav_link>
        
        <.nav_link href={~p"/threads"} icon="hero-chat-bubble-left-right" active={@active_tab == :threads}>
          Knowledge Hub
        </.nav_link>

        <.nav_link href={~p"/projects"} icon="hero-rectangle-stack" active={@active_tab == :projects}>
          Projects
        </.nav_link>

        <.nav_link href={~p"/dms"} icon="hero-envelope" active={@active_tab == :messages}>
          Messages
        </.nav_link>
      </div>

      <div class="p-4 border-t border-base-300">
        <div class="flex items-center gap-3">
          <div class="avatar placeholder">
            <div class="bg-neutral text-neutral-content rounded-full w-10">
              <span class="text-xs">{String.at(@current_user.email, 0) |> String.upcase()}</span>
            </div>
          </div>
          <div class="flex flex-col overflow-hidden">
            <span class="text-sm font-medium truncate">{@current_user.email}</span>
            <span class="text-xs text-base-content/70">Online</span>
          </div>
        </div>
      </div>
    </nav>
    """
  end

  attr :href, :string, required: true
  attr :icon, :string, required: true
  attr :active, :boolean, default: false
  slot :inner_block, required: true

  defp nav_link(assigns) do
    ~H"""
    <.link
      navigate={@href}
      class={[
        "flex items-center gap-3 px-3 py-2 rounded-lg text-sm font-medium transition-colors group",
        if(@active, do: "bg-primary/10 text-primary", else: "text-base-content/70 hover:bg-base-300 hover:text-base-content")
      ]}
    >
      <.icon name={@icon} class={[
        "w-5 h-5",
        if(@active, do: "text-primary", else: "text-base-content/50 group-hover:text-base-content/80")
      ]} />
      {render_slot(@inner_block)}
    </.link>
    """
  end
end

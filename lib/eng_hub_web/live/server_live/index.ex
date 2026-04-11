defmodule EngHubWeb.ServerLive.Index do
  use EngHubWeb, :live_view
  alias EngHub.Communities

  @impl true
  def mount(_params, _session, socket) do
    servers = Communities.list_user_servers(socket.assigns.current_user.id)

    if server = List.first(servers) do
      {:ok, push_navigate(socket, to: ~p"/servers/#{server.id}")}
    else
      {:ok,
       socket
       |> assign(:servers, [])
       |> assign(:form, to_form(%{"name" => ""}))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user} servers={@servers}>
      <div class="h-screen flex items-center justify-center bg-base-100 overflow-hidden relative">
        <div class="max-w-md w-full p-8 bg-white/5 backdrop-blur-3xl rounded-[32px] shadow-2xl border border-white/5 animate-in fade-in zoom-in duration-500 overflow-hidden relative">
          <div class="absolute -top-24 -right-24 w-48 h-48 bg-primary/10 rounded-full blur-3xl"></div>
          <div class="absolute -bottom-24 -left-24 w-48 h-48 bg-primary/10 rounded-full blur-3xl"></div>

          <div class="w-20 h-20 bg-primary/20 rounded-3xl flex items-center justify-center mx-auto mb-6 relative rotate-3 shadow-xl shadow-primary/10">
            <.icon name="hero-sparkles" class="h-10 w-10 text-primary" />
          </div>

          <h1 class="text-3xl font-black text-white text-center mb-2 uppercase tracking-tighter italic">EngHub Servers</h1>
          <p class="text-white/40 text-center mb-10 px-4 text-sm font-medium leading-relaxed">
            Create a server to organize your team's projects, files, and real-time collaboration channels.
          </p>

          <.form for={@form} phx-submit="create_server" class="space-y-6 relative">
            <div>
              <label class="block text-[10px] font-black text-white/30 uppercase tracking-[0.2em] mb-3 ml-1">
                Server Name
              </label>
              <input
                type="text"
                name="name"
                value={@form[:name].value}
                class="w-full bg-black/40 border border-white/5 rounded-xl p-4 text-white focus:ring-2 ring-primary/50 transition-all placeholder:text-white/10 shadow-inner"
                placeholder="e.g. Apollo Mission Control"
                required
                autofocus
              />
            </div>

            <button
              type="submit"
              class="w-full bg-primary hover:scale-[1.02] active:scale-[0.98] text-white font-black py-4 rounded-xl transition-all duration-300 shadow-xl shadow-primary/20 group flex items-center justify-center gap-2"
            >
              <span>Initialize Server</span>
              <.icon name="hero-arrow-right-solid" class="h-4 w-4 group-hover:translate-x-1 transition-transform" />
            </button>
          </.form>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def handle_event("create_server", %{"name" => name}, socket) do
    case Communities.create_server(%{"name" => name}, socket.assigns.current_user.id) do
      {:ok, server} ->
        {:noreply, push_navigate(socket, to: ~p"/servers/#{server.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, :form, to_form(changeset))}
    end
  end
end

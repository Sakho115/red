defmodule EngHubWeb.ThreadLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Discussions
  alias EngHub.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="p-8 max-w-7xl mx-auto">
        <header class="flex items-center justify-between mb-8">
          <div>
            <h1 class="text-4xl font-black text-white italic tracking-tighter uppercase">Technical Threads</h1>
            <p class="text-white/40 font-medium">Deep-dive discussions and engineering Q&A.</p>
          </div>
          <.button variant="primary" navigate={~p"/threads/new"} class="shadow-xl shadow-primary/20">
            <.icon name="hero-plus" /> New Thread
          </.button>
        </header>

        <div class="bg-white/5 border border-white/5 backdrop-blur-xl rounded-[32px] overflow-hidden">
          <.table
            id="threads"
            rows={@streams.threads}
            row_click={fn {_id, thread} -> JS.navigate(~p"/threads/#{thread}") end}
          >
            <:col :let={{_id, thread}} label="Topic" class="font-bold text-white italic">
              <span class="px-2 py-0.5 rounded-md bg-white/5 text-[10px] uppercase tracking-widest mr-2">{thread.category}</span>
              {thread.title}
            </:col>
            <:col :let={{_id, thread}} label="Content Preview" class="text-white/40 truncate max-w-md">{thread.content}</:col>
            <:action :let={{_id, thread}}>
              <div class="sr-only">
                <.link navigate={~p"/threads/#{thread}"}>Show</.link>
              </div>
              <.link
                :if={Projects.can?(thread.project_id, @current_user.id, "editor")}
                navigate={~p"/threads/#{thread}/edit"}
                class="text-primary hover:underline font-bold"
              >
                Edit
              </.link>
            </:action>
            <:action :let={{id, thread}}>
              <.link
                :if={Projects.can?(thread.project_id, @current_user.id, "editor")}
                phx-click={JS.push("delete", value: %{id: thread.id}) |> hide("##{id}")}
                data-confirm="Are you sure?"
                class="text-error/60 hover:text-error transition-colors"
              >
                Delete
              </.link>
            </:action>
          </.table>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Discussions.subscribe()

    {:ok,
     socket
     |> assign(:page_title, "Listing Threads")
     |> stream(:threads, list_threads(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    thread = Discussions.get_thread!(id)

    if Projects.can?(thread.project_id, socket.assigns.current_user.id, "editor") do
      {:ok, _} = Discussions.delete_thread(thread)
      {:noreply, stream_delete(socket, :threads, thread)}
    else
      {:noreply, put_flash(socket, :error, "You do not have permission to delete this thread.")}
    end
  end

  @impl true
  def handle_info({Discussions, :thread_created, thread}, socket) do
    {:noreply, stream_insert(socket, :threads, thread, at: 0)}
  end

  @impl true
  def handle_info({Discussions, :thread_updated, thread}, socket) do
    {:noreply, stream_insert(socket, :threads, thread)}
  end

  @impl true
  def handle_info({Discussions, :thread_deleted, thread}, socket) do
    {:noreply, stream_delete(socket, :threads, thread)}
  end

  defp list_threads(user_id) do
    Discussions.list_threads_for_user(user_id)
  end
end

defmodule EngHubWeb.FileLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Vault
  alias EngHub.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="p-8 max-w-7xl mx-auto">
        <header class="flex items-center justify-between mb-8">
          <div>
            <h1 class="text-4xl font-black text-white italic tracking-tighter uppercase">Secure Vault</h1>
            <p class="text-white/40 font-medium">Manage and version-control your engineering resources.</p>
          </div>
          <.button variant="primary" navigate={~p"/files/new"} class="shadow-xl shadow-primary/20">
            <.icon name="hero-plus" /> New File
          </.button>
        </header>

        <div class="bg-white/5 border border-white/5 backdrop-blur-xl rounded-[32px] overflow-hidden">
          <.table
            id="files"
            rows={@streams.files}
            row_click={fn {_id, file} -> JS.navigate(~p"/files/#{file}") end}
          >
            <:col :let={{_id, file}} label="Filename" class="font-bold text-white italic">
              <.icon name="hero-document" class="w-4 h-4 mr-2 opacity-50" />
              {file.filename}
            </:col>
            <:col :let={{_id, file}} label="Mime Type" class="text-[10px] font-black uppercase tracking-widest text-white/30">{file.mime_type}</:col>
            <:col :let={{_id, file}} label="Size" class="text-white/40 tabular-nums">{(file.size / 1024) |> Float.round(2)} KB</:col>
            <:action :let={{_id, file}}>
              <div class="sr-only">
                <.link navigate={~p"/files/#{file}"}>Show</.link>
              </div>
              <.link
                :if={Projects.can?(file.project_id, @current_user.id, "editor")}
                navigate={~p"/files/#{file}/edit"}
                class="text-primary hover:underline font-bold"
              >
                Edit
              </.link>
            </:action>
            <:action :let={{id, file}}>
              <.link
                :if={Projects.can?(file.project_id, @current_user.id, "editor")}
                phx-click={JS.push("delete", value: %{id: file.id}) |> hide("##{id}")}
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
    {:ok,
     socket
     |> assign(:page_title, "Listing Files")
     |> stream(:files, list_files(socket.assigns.current_user.id))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    file = Vault.get_file!(id)

    if Projects.can?(file.project_id, socket.assigns.current_user.id, "editor") do
      {:ok, _} = Vault.delete_file(file)
      {:noreply, stream_delete(socket, :files, file)}
    else
      {:noreply, put_flash(socket, :error, "You do not have permission to delete this file.")}
    end
  end

  defp list_files(user_id) do
    Vault.list_files_for_user(user_id)
  end
end

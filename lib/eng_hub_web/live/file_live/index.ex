defmodule EngHubWeb.FileLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Vault

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Files
        <:actions>
          <.button variant="primary" navigate={~p"/files/new"}>
            <.icon name="hero-plus" /> New File
          </.button>
        </:actions>
      </.header>

      <.table
        id="files"
        rows={@streams.files}
        row_click={fn {_id, file} -> JS.navigate(~p"/files/#{file}") end}
      >
        <:col :let={{_id, file}} label="Filename">{file.filename}</:col>
        <:col :let={{_id, file}} label="Storage path">{file.storage_path}</:col>
        <:col :let={{_id, file}} label="Mime type">{file.mime_type}</:col>
        <:col :let={{_id, file}} label="Size">{file.size}</:col>
        <:action :let={{_id, file}}>
          <div class="sr-only">
            <.link navigate={~p"/files/#{file}"}>Show</.link>
          </div>
          <.link navigate={~p"/files/#{file}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, file}}>
          <.link
            phx-click={JS.push("delete", value: %{id: file.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Files")
     |> stream(:files, list_files())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    file = Vault.get_file!(id)
    {:ok, _} = Vault.delete_file(file)

    {:noreply, stream_delete(socket, :files, file)}
  end

  defp list_files() do
    Vault.list_files()
  end
end

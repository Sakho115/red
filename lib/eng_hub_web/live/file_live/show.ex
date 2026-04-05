defmodule EngHubWeb.FileLive.Show do
  use EngHubWeb, :live_view

  alias EngHub.Vault

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        File {@file.id}
        <:subtitle>This is a file record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/files"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/files/#{@file}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit file
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Filename">{@file.filename}</:item>
        <:item title="Storage path">{@file.storage_path}</:item>
        <:item title="Mime type">{@file.mime_type}</:item>
        <:item title="Size">{@file.size}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show File")
     |> assign(:file, Vault.get_file!(id))}
  end
end

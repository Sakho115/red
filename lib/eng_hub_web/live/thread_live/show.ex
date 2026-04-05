defmodule EngHubWeb.ThreadLive.Show do
  use EngHubWeb, :live_view

  alias EngHub.Discussions

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Thread {@thread.id}
        <:subtitle>This is a thread record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/threads"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/threads/#{@thread}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit thread
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Category">{@thread.category}</:item>
        <:item title="Title">{@thread.title}</:item>
        <:item title="Content">{@thread.content}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Thread")
     |> assign(:thread, Discussions.get_thread!(id))}
  end
end

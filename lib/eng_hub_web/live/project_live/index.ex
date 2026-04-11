defmodule EngHubWeb.ProjectLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Projects

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="p-8 max-w-7xl mx-auto">
        <header class="flex items-center justify-between mb-8">
          <div>
            <h1 class="text-4xl font-black text-white italic tracking-tighter uppercase">EngHub Projects</h1>
            <p class="text-white/40 font-medium">Manage and collaborate on engineering workspaces.</p>
          </div>
          <.button variant="primary" navigate={~p"/projects/new"} class="shadow-xl shadow-primary/20">
            <.icon name="hero-plus" /> New Project
          </.button>
        </header>

        <div class="bg-white/5 border border-white/5 backdrop-blur-xl rounded-[32px] overflow-hidden">
          <.table
            id="projects"
            rows={@streams.projects}
            row_click={fn {_id, project} -> JS.navigate(~p"/projects/#{project}") end}
          >
            <:col :let={{_id, project}} label="Name" class="font-bold text-white italic">{project.name}</:col>
            <:col :let={{_id, project}} label="Description" class="text-white/40">{project.description}</:col>
            <:action :let={{_id, project}}>
              <div class="sr-only">
                <.link navigate={~p"/projects/#{project}"}>Show</.link>
              </div>
              <.link
                :if={Projects.can?(project.id, @current_user.id, "admin")}
                navigate={~p"/projects/#{project}/edit"}
                class="text-primary hover:underline font-bold"
              >
                Edit
              </.link>
            </:action>
            <:action :let={{id, project}}>
              <.link
                :if={Projects.can?(project.id, @current_user.id, "owner")}
                phx-click={JS.push("delete", value: %{id: project.id}) |> hide("##{id}")}
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
     |> assign(:page_title, "Listing Projects")
     |> stream(:projects, list_projects())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    if Projects.can?(id, socket.assigns.current_user.id, "owner") do
      project = Projects.get_project!(id)
      {:ok, _} = Projects.delete_project(project)
      {:noreply, stream_delete(socket, :projects, project)}
    else
      {:noreply, put_flash(socket, :error, "Only owners can delete projects.")}
    end
  end

  defp list_projects() do
    Projects.list_projects()
  end
end

defmodule EngHubWeb.ProjectLive.Show do
  use EngHubWeb, :live_view

  alias EngHub.Projects
  alias EngHubWeb.Live.Authorize

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Project {@project.id}
        <:subtitle>This is a project record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/projects"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button
            :if={Projects.can?(@project.id, @current_user.id, "admin")}
            variant="primary"
            navigate={~p"/projects/#{@project}/edit?return_to=show"}
          >
            <.icon name="hero-pencil-square" /> Edit project
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Name">{@project.name}</:item>
        <:item title="Description">{@project.description}</:item>
      </.list>

      <section class="mt-12">
        <.header>
          Project Members
          <:subtitle>Who has access to this project.</:subtitle>
        </.header>

        <ul id="members" class="mt-4 divide-y border rounded-lg bg-white overflow-hidden">
          <li :for={member <- @members} class="flex items-center justify-between p-4">
            <div class="flex items-center">
              <img
                src={
                  member.user.avatar_url ||
                    "https://ui-avatars.com/api/?name=#{member.user.username}&size=100"
                }
                class="h-10 w-10 rounded-full mr-3"
              />
              <div>
                <div class="font-bold text-gray-900">{member.user.username}</div>
                <div class="text-sm text-gray-500">{member.user.email}</div>
              </div>
            </div>
            <div class="flex items-center">
              <span class={[
                "px-2.5 py-0.5 rounded-full text-xs font-medium uppercase tracking-wider",
                member.role == "owner" && "bg-purple-100 text-purple-800",
                member.role == "admin" && "bg-red-100 text-red-800",
                member.role == "editor" && "bg-blue-100 text-blue-800",
                member.role == "viewer" && "bg-gray-100 text-gray-800"
              ]}>
                {member.role}
              </span>
            </div>
          </li>
        </ul>
      </section>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    case Authorize.check_permission(socket, id, "viewer") do
      {:ok, socket} ->
        socket = Authorize.assign_project_role(socket, id)
        members = Projects.list_members(id)

        {:ok,
         socket
         |> assign(:page_title, "Show Project")
         |> assign(:project, Projects.get_project!(id))
         |> assign(:members, members)}

      {:error, socket} ->
        {:ok, socket}
    end
  end
end

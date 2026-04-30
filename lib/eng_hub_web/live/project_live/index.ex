defmodule EngHubWeb.ProjectLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Projects
  alias EngHub.Projects.Project

  @impl true
  def mount(_params, session, socket) do
    {:ok, user} = EngHub.Identity.get(session["current_user_id"])

    socket =
      socket
      |> assign(:current_user, user)
      |> assign(:projects, Projects.list_projects())
      |> assign(:form, to_form(Projects.change_project(%Project{})))

    action = String.to_existing_atom(to_string(session["nested_action"] || "projects"))

    {:ok,
     apply_action(assign(socket, :nested_action, action), action, session["nested_params"] || %{})}
  end

  defp apply_action(socket, :projects, _params) do
    socket
    |> assign(:page_title, "Listing Projects")
    |> assign(:project, nil)
    |> assign(:show_modal, false)
    |> assign(:show_project, false)
  end

  defp apply_action(socket, :projects_new, _params) do
    socket
    |> assign(:page_title, "New Project")
    |> assign(:project, %Project{})
    |> assign(:show_modal, true)
    |> assign(:show_project, false)
    |> assign(:form, to_form(Projects.change_project(%Project{})))
  end

  defp apply_action(socket, :projects_edit, %{"id" => id}) do
    project = Projects.get_project!(id)

    socket
    |> assign(:page_title, "Edit Project")
    |> assign(:project, project)
    |> assign(:show_modal, true)
    |> assign(:show_project, false)
    |> assign(:form, to_form(Projects.change_project(project)))
  end

  defp apply_action(socket, :projects_show, %{"id" => id}) do
    project = Projects.get_project!(id)

    socket
    |> assign(:page_title, "Show Project")
    |> assign(:project, project)
    |> assign(:show_modal, false)
    |> assign(:show_project, true)
  end

  @impl true
  def handle_event("validate", %{"project" => project_params}, socket) do
    changeset =
      socket.assigns.project
      |> Projects.change_project(project_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  def handle_event("save", %{"project" => project_params}, socket) do
    save_project(socket, socket.assigns.nested_action, project_params)
  end

  def handle_event("delete", %{"id" => id}, socket) do
    project = Projects.get_project!(id)
    {:ok, _} = Projects.delete_project(project)

    {:noreply, assign(socket, :projects, Projects.list_projects())}
  end

  defp save_project(socket, :projects_edit, project_params) do
    case Projects.update_project(socket.assigns.project, project_params) do
      {:ok, project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project updated successfully")
         |> push_navigate(to: ~p"/projects")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_project(socket, :projects_new, project_params) do
    # create_project_for_user requires an owner_id
    case Projects.create_project_for_user(project_params, socket.assigns.current_user.id) do
      {:ok, project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project created successfully")
         |> push_navigate(to: ~p"/projects")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-full flex flex-col bg-base-100 relative">
      <%= if @show_project do %>
        <!-- Show Project View -->
        <div class="p-6">
          <div class="mb-4">
            <.link navigate={~p"/projects"} class="text-sm text-base-content/60 hover:text-primary">
              &larr; Back to projects
            </.link>
          </div>
          <h1 class="text-2xl font-bold mb-2">Show Project: {@project.name}</h1>
          <div class="p-4 border border-base-300 rounded-lg bg-base-200">
            <p><strong>Description:</strong> {@project.description}</p>
          </div>
          <div class="mt-4 flex gap-2">
            <.link navigate={~p"/projects/#{@project.id}/edit"} class="btn btn-sm btn-outline">
              Edit
            </.link>
          </div>
        </div>
      <% else %>
        <!-- Projects List View -->
        <div class="p-8 border-b border-base-300 flex items-center justify-between shrink-0 bg-base-100/80 backdrop-blur-md sticky top-0 z-10">
          <div>
            <h2 class="text-3xl font-black tracking-tight flex items-center gap-3">
              <.icon name="hero-folder-open" class="w-8 h-8 text-primary" /> Project Workspaces
            </h2>
            <p class="text-base-content/60 text-sm mt-2 max-w-xl">
              Create and manage isolated environments for your engineering projects. Each project gets its own dedicated channels, members, and resources.
            </p>
          </div>
          <.link
            navigate={~p"/projects/new"}
            class="btn btn-primary shadow-lg hover:shadow-primary/20 transition-all duration-300 group"
          >
            <.icon
              name="hero-plus-circle"
              class="w-5 h-5 mr-2 group-hover:rotate-90 transition-transform duration-300"
            /> Create Project
          </.link>
        </div>

        <div class="flex-1 overflow-y-auto p-8 bg-base-200/20">
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-7xl mx-auto">
            <%= for project <- @projects do %>
              <div
                id={"projects-#{project.id}"}
                class="group relative flex flex-col bg-base-100 border border-base-300/60 rounded-2xl p-6 shadow-sm hover:shadow-xl hover:border-primary/40 transition-all duration-300 ease-out overflow-hidden"
              >
                <!-- Decorative gradient background -->
                <div class="absolute inset-0 bg-gradient-to-br from-primary/5 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500">
                </div>

                <div class="relative flex justify-between items-start mb-4">
                  <div class="w-12 h-12 rounded-xl bg-primary/10 flex items-center justify-center text-primary group-hover:scale-110 transition-transform duration-300 ease-out">
                    <.icon name="hero-cube" class="w-6 h-6" />
                  </div>

                  <div class="flex items-center opacity-0 group-hover:opacity-100 transition-opacity duration-300 bg-base-200/80 backdrop-blur-sm rounded-lg p-1 border border-base-300">
                    <.link
                      navigate={~p"/projects/#{project.id}/edit"}
                      class="p-2 hover:text-primary transition-colors rounded-md hover:bg-base-300"
                      title="Edit"
                    >
                      <.icon name="hero-pencil" class="w-4 h-4" />
                    </.link>
                    <button
                      phx-click="delete"
                      phx-value-id={project.id}
                      data-confirm="Are you sure you want to delete this project?"
                      class="p-2 hover:text-error transition-colors rounded-md hover:bg-base-300"
                      title="Delete"
                    >
                      <.icon name="hero-trash" class="w-4 h-4" />
                    </button>
                  </div>
                </div>

                <div class="relative flex-1">
                  <.link
                    navigate={~p"/projects/#{project.id}"}
                    class="text-xl font-bold mb-2 group-hover:text-primary transition-colors block"
                  >
                    {project.name}
                  </.link>
                  <p class="text-sm text-base-content/70 line-clamp-3 leading-relaxed mb-6">
                    {project.description}
                  </p>
                </div>

                <div class="relative flex items-center justify-between pt-4 border-t border-base-300/50 mt-auto">
                  <div class="flex -space-x-2">
                    <div class="w-7 h-7 rounded-full bg-base-300 border-2 border-base-100 flex items-center justify-center text-[10px] font-bold">
                      1
                    </div>
                  </div>
                  <.link
                    navigate={~p"/projects/#{project.id}"}
                    class="text-sm font-medium text-primary flex items-center gap-1 group-hover:gap-2 transition-all"
                  >
                    View Project <.icon name="hero-arrow-right" class="w-4 h-4" />
                  </.link>
                </div>
              </div>
            <% end %>
          </div>

          <%= if Enum.empty?(@projects) do %>
            <div class="flex flex-col items-center justify-center py-20 text-center">
              <div class="w-24 h-24 rounded-full bg-base-300/50 flex items-center justify-center text-base-content/30 mb-6 group-hover:scale-110 transition-transform">
                <.icon name="hero-folder-open" class="w-12 h-12" />
              </div>
              <h3 class="text-2xl font-bold mb-2">No Projects Yet</h3>
              <p class="text-base-content/60 max-w-md mb-8 leading-relaxed">
                Create a project to start organizing your team's work, repositories, and documentation in one place.
              </p>
              <.link
                navigate={~p"/projects/new"}
                class="btn btn-primary shadow-lg hover:shadow-primary/20 transition-all group"
              >
                <.icon name="hero-plus" class="w-5 h-5 mr-2" /> Create Your First Project
              </.link>
            </div>
          <% end %>
        </div>
      <% end %>
      
    <!-- Modal for New/Edit -->
      <%= if @show_modal do %>
        <div class="absolute inset-0 bg-black/50 z-50 flex items-center justify-center p-4">
          <div class="bg-base-100 rounded-xl max-w-lg w-full p-6 shadow-2xl relative">
            <.link
              navigate={~p"/projects"}
              class="absolute top-4 right-4 text-base-content/50 hover:text-base-content"
            >
              <.icon name="hero-x-mark" class="w-5 h-5" />
            </.link>

            <h3 class="text-xl font-bold mb-4">{@page_title}</h3>

            <.form for={@form} id="project-form" phx-change="validate" phx-submit="save">
              <div class="flex flex-col gap-4">
                <.input field={@form[:name]} type="text" label="Name" />
                <.input field={@form[:description]} type="textarea" label="Description" />

                <div class="flex justify-end gap-2 mt-4">
                  <.link navigate={~p"/projects"} class="btn btn-ghost">Cancel</.link>
                  <button type="submit" class="btn btn-primary" phx-disable-with="Saving...">
                    Save
                  </button>
                </div>
              </div>
            </.form>
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end

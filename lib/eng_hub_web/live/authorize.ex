defmodule EngHubWeb.Live.Authorize do
  @moduledoc """
  Helper functions for authorizing users in LiveViews.
  """
  import Phoenix.LiveView
  import Phoenix.Component
  alias EngHub.Projects

  @doc """
  Checks if the current user has the required permission for the project.
  Redirects if unauthorized.
  """
  def check_permission(socket, project_id, min_role) do
    user = socket.assigns.current_user

    if is_nil(project_id) || Projects.can?(project_id, user.id, min_role) do
      {:ok, socket}
    else
      socket =
        socket
        |> put_flash(:error, "You do not have permission to access this project resource.")
        |> push_navigate(to: "/projects")

      {:error, socket}
    end
  end

  @doc """
  Assigns the user's role in the current project to the socket.
  """
  def assign_project_role(socket, project_id) do
    user = socket.assigns.current_user
    role = Projects.get_member_role(project_id, user.id)
    assign(socket, :project_role, role)
  end
end

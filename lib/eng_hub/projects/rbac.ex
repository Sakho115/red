defmodule EngHub.Projects.RBAC do
  @moduledoc """
  Role-Based Access Control for EngHub projects.

  Roles (in ascending order of privilege):
    :viewer  — can read project content
    :editor  — can create/edit content (posts, files, threads, channels)
    :admin   — can manage members and update project settings
    :owner   — full control, cannot be removed

  The project `owner_id` field implicitly grants owner-level access.
  """

  import Ecto.Query
  alias EngHub.Repo
  alias EngHub.Projects.{Project, ProjectMember}

  @roles ~w(viewer editor admin owner)
  @role_order %{"viewer" => 0, "editor" => 1, "admin" => 2, "owner" => 3}

  @doc "All valid role strings."
  def roles, do: @roles

  # ---------------------------------------------------------------------------
  # Membership queries
  # ---------------------------------------------------------------------------

  @doc "Returns the `ProjectMember` for `user_id` in `project_id`, or nil."
  def get_member(nil, _user_id), do: nil
  def get_member(_project_id, nil), do: nil

  def get_member(project_id, user_id) do
    Repo.get_by(ProjectMember, project_id: project_id, user_id: user_id)
  end

  @doc """
  Returns the effective role string for `user_id` in the given project.
  Returns `\"owner\"` when the user is the project owner, their explicit member
  role otherwise, or `nil` when they are not a member at all.
  """
  def get_role(%Project{owner_id: owner_id}, user_id) when owner_id == user_id, do: "owner"

  def get_role(%Project{id: project_id}, user_id) do
    case get_member(project_id, user_id) do
      %ProjectMember{role: role} -> role
      nil -> nil
    end
  end

  def get_role(project_id, user_id) when is_integer(project_id) or is_binary(project_id) do
    project = Repo.get!(Project, project_id)
    get_role(project, user_id)
  end

  # ---------------------------------------------------------------------------
  # Permission helpers
  # ---------------------------------------------------------------------------

  @doc "Returns `true` when the user has *at least* the given `min_role` in the project."
  def can?(%Project{} = project, user_id, min_role) do
    role = get_role(project, user_id)
    role_gte?(role, min_role)
  end

  def can?(project_id, user_id, min_role) do
    role = get_role(project_id, user_id)
    role_gte?(role, min_role)
  end

  @doc "Raises `EngHub.Projects.RBAC.Unauthorized` unless the user has `min_role`."
  def authorize!(%Project{} = project, user_id, min_role) do
    unless can?(project, user_id, min_role) do
      raise EngHub.Projects.RBAC.UnauthorizedError,
        message: "You need the #{min_role} role to perform this action."
    end

    :ok
  end

  # ---------------------------------------------------------------------------
  # Member management
  # ---------------------------------------------------------------------------

  def upsert_member(nil, _user_id, _role), do: {:error, :invalid_project}
  def upsert_member(_project_id, nil, _role), do: {:error, :invalid_user}

  def upsert_member(project_id, user_id, role) when role in @roles do
    case get_member(project_id, user_id) do
      nil ->
        %ProjectMember{}
        |> ProjectMember.changeset(%{project_id: project_id, user_id: user_id, role: role})
        |> Repo.insert()

      member ->
        member
        |> ProjectMember.changeset(%{role: role})
        |> Repo.update()
    end
  end

  @doc "Removes a user from a project (only an admin/owner may do this)."
  def remove_member(project_id, user_id) do
    case get_member(project_id, user_id) do
      nil -> {:error, :not_found}
      member -> Repo.delete(member)
    end
  end

  @doc "Lists all members of a project with their roles, preloading `:user`."
  def list_members(project_id) do
    from(m in ProjectMember,
      where: m.project_id == ^project_id,
      preload: [:user]
    )
    |> Repo.all()
  end

  # ---------------------------------------------------------------------------
  # Private helpers
  # ---------------------------------------------------------------------------

  defp role_gte?(nil, _min), do: false

  defp role_gte?(role, min_role) do
    Map.get(@role_order, to_string(role), -1) >= Map.get(@role_order, to_string(min_role), 999)
  end
end

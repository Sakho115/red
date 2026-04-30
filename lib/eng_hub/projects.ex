defmodule EngHub.Projects do
  @moduledoc """
  The Projects context.
  """

  import Ecto.Query, warn: false
  alias EngHub.Repo

  alias EngHub.Projects.Project
  alias EngHub.Projects.ProjectMember

  @doc """
  Returns the list of projects.

  ## Examples

      iex> list_projects()
      [%Project{}, ...]

  """
  def list_projects do
    Repo.all(Project)
  end

  @doc """
  Gets a single project.

  Raises `Ecto.NoResultsError` if the Project does not exist.

  ## Examples

      iex> get_project!(123)
      %Project{}

      iex> get_project!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project!(id), do: Repo.get!(Project, id)

  @doc """
  Gets a project by its associated channel_id.
  """
  def get_project_by_channel(channel_id) do
    from(p in Project, where: p.channel_id == ^channel_id)
    |> Repo.one()
  end

  @doc """
  Creates a project.

  ## Examples

      iex> create_project(%{field: value})
      {:ok, %Project{}}

      iex> create_project(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project(attrs) do
    %Project{}
    |> Project.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project.

  ## Examples

      iex> update_project(project, %{field: new_value})
      {:ok, %Project{}}

      iex> update_project(project, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project(%Project{} = project, attrs) do
    project
    |> Project.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project.

  ## Examples

      iex> delete_project(project)
      {:ok, %Project{}}

      iex> delete_project(project)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project(%Project{} = project) do
    Repo.transaction(fn ->
      from(m in ProjectMember, where: m.project_id == ^project.id) |> Repo.delete_all()
      
      from(c in EngHub.Communities.Channel, where: c.project_id == ^project.id)
      |> Repo.all()
      |> Enum.each(&EngHub.Communities.delete_channel/1)
      
      Repo.delete!(project)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project changes.

  ## Examples

      iex> change_project(project)
      %Ecto.Changeset{data: %Project{}}

  """
  def change_project(%Project{} = project, attrs \\ %{}) do
    Project.changeset(project, attrs)
  end

  alias EngHub.Projects.ProjectMember

  @doc """
  Returns the list of project_members.

  ## Examples

      iex> list_project_members()
      [%ProjectMember{}, ...]

  """
  def list_project_members do
    Repo.all(ProjectMember)
  end

  @doc """
  Gets a single project_member.

  Raises `Ecto.NoResultsError` if the Project member does not exist.

  ## Examples

      iex> get_project_member!(123)
      %ProjectMember{}

      iex> get_project_member!(456)
      ** (Ecto.NoResultsError)

  """
  def get_project_member!(id), do: Repo.get!(ProjectMember, id)

  @doc """
  Creates a project_member.

  ## Examples

      iex> create_project_member(%{field: value})
      {:ok, %ProjectMember{}}

      iex> create_project_member(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_project_member(attrs) do
    %ProjectMember{}
    |> ProjectMember.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a project_member.

  ## Examples

      iex> update_project_member(project_member, %{field: new_value})
      {:ok, %ProjectMember{}}

      iex> update_project_member(project_member, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_project_member(%ProjectMember{} = project_member, attrs) do
    project_member
    |> ProjectMember.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a project_member.

  ## Examples

      iex> delete_project_member(project_member)
      {:ok, %ProjectMember{}}

      iex> delete_project_member(project_member)
      {:error, %Ecto.Changeset{}}

  """
  def delete_project_member(%ProjectMember{} = project_member) do
    Repo.delete(project_member)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking project_member changes.

  ## Examples

      iex> change_project_member(project_member)
      %Ecto.Changeset{data: %ProjectMember{}}

  """
  def change_project_member(%ProjectMember{} = project_member, attrs \\ %{}) do
    ProjectMember.changeset(project_member, attrs)
  end

  # ---------------------------------------------------------------------------
  # RBAC helpers (delegate to EngHub.Projects.RBAC)
  # ---------------------------------------------------------------------------

  alias EngHub.Projects.RBAC

  @doc "Returns the role string for `user_id` in `project`, or `nil` if not a member."
  defdelegate get_member_role(project, user_id), to: RBAC, as: :get_role

  @doc "Returns `true` when `user_id` has at least `min_role` in `project`."
  defdelegate can?(project, user_id, min_role), to: RBAC

  @doc "Raises `EngHub.Projects.RBAC.UnauthorizedError` unless `user_id` meets `min_role`."
  defdelegate authorize!(project, user_id, min_role), to: RBAC

  @doc "Lists all members of `project_id` with preloaded `:user`."
  defdelegate list_members(project_id), to: RBAC

  @doc "Adds or updates a member's role in a project. Returns `{:ok, member}` or `{:error, changeset}`."
  defdelegate upsert_member(project_id, user_id, role), to: RBAC

  @doc "Removes a member from a project. Returns `{:ok, member}` or `{:error, :not_found}`."
  defdelegate remove_member(project_id, user_id), to: RBAC

  @doc """
  Creates a project and automatically adds the creator as `:owner`.
  """
  def create_project_for_user(attrs, owner_id) do
    Repo.transaction(fn ->
      case create_project(attrs) do
        {:ok, project} ->
          case RBAC.upsert_member(project.id, owner_id, "owner") do
            {:ok, _member} -> project
            {:error, reason} -> Repo.rollback(reason)
          end

        {:error, reason} ->
          Repo.rollback(reason)
      end
    end)
  end
end

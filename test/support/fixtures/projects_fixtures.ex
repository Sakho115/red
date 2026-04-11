defmodule EngHub.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EngHub.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {owner_id, attrs} = attrs |> Map.new() |> Map.pop(:owner_id)

    if owner_id do
      {:ok, project} =
        attrs
        |> Enum.into(%{
          description: "some description",
          name: "some name"
        })
        |> EngHub.Projects.create_project_for_user(owner_id)

      project
    else
      {:ok, project} =
        attrs
        |> Enum.into(%{
          description: "some description",
          name: "some name"
        })
        |> EngHub.Projects.create_project()

      project
    end
  end

  @doc """
  Generate a project_member.
  """
  def project_member_fixture(attrs \\ %{}) do
    project = project_fixture()
    user = EngHub.IdentityFixtures.user_fixture()

    {:ok, project_member} =
      attrs
      |> Enum.into(%{
        role: "editor",
        project_id: project.id,
        user_id: user.id
      })
      |> EngHub.Projects.create_project_member()

    project_member
  end
end

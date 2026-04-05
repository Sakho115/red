defmodule EngHub.ProjectsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EngHub.Projects` context.
  """

  @doc """
  Generate a project.
  """
  def project_fixture(attrs \\ %{}) do
    {:ok, project} =
      attrs
      |> Enum.into(%{
        description: "some description",
        name: "some name"
      })
      |> EngHub.Projects.create_project()

    project
  end

  @doc """
  Generate a project_member.
  """
  def project_member_fixture(attrs \\ %{}) do
    {:ok, project_member} =
      attrs
      |> Enum.into(%{
        role: "some role"
      })
      |> EngHub.Projects.create_project_member()

    project_member
  end
end

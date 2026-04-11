defmodule EngHub.VaultFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `EngHub.Vault` context.
  """

  @doc """
  Generate a file.
  """
  def file_fixture(attrs \\ %{}) do
    attrs = Map.new(attrs)
    project_id = Map.get(attrs, :project_id) || EngHub.ProjectsFixtures.project_fixture().id
    uploader_id = Map.get(attrs, :uploader_id) || EngHub.IdentityFixtures.user_fixture().id

    {:ok, file} =
      attrs
      |> Enum.into(%{
        filename: "some filename",
        mime_type: "some mime_type",
        project_id: project_id,
        uploader_id: uploader_id,
        size: 42,
        storage_path: "some storage_path"
      })
      |> EngHub.Vault.create_file()

    file
  end

  @doc """
  Generate a file_version.
  """
  def file_version_fixture(attrs \\ %{}) do
    {:ok, file_version} =
      attrs
      |> Enum.into(%{
        storage_path: "some storage_path",
        version_number: 42
      })
      |> EngHub.Vault.create_file_version()

    file_version
  end
end

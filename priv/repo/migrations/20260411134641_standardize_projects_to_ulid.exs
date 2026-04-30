defmodule EngHub.Repo.Migrations.StandardizeProjectsToUlid do
  use Ecto.Migration

  def up do
    # 1. Drop constraints referencing projects
    drop_if_exists constraint(:channels, "channels_project_id_fkey")
    drop_if_exists constraint(:project_members, "project_members_project_id_fkey")
    drop_if_exists constraint(:files, "files_project_id_fkey")
    drop_if_exists constraint(:threads, "threads_project_id_fkey")
    drop_if_exists constraint(:hackathons, "hackathons_project_id_fkey")
    drop_if_exists constraint(:listings, "listings_project_id_fkey")

    # 2. Drop and recreate projects table with ULID support
    drop_if_exists table(:projects)

    create table(:projects, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :string
      add :owner_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :server_id, references(:servers, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:projects, [:owner_id])
    create index(:projects, [:server_id])

    # 3. Alter referencing columns - Drop and Re-add for type change
    alter table(:channels) do
      remove :project_id
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
    end

    alter table(:project_members) do
      remove :project_id
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
    end

    alter table(:files) do
      remove :project_id
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
    end

    alter table(:threads) do
      remove :project_id
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
    end

    alter table(:hackathons) do
      remove :project_id
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
    end

    alter table(:listings) do
      remove :project_id
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
    end
  end

  def down do
    raise "Irreversible migration"
  end
end

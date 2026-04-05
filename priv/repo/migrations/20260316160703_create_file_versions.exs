defmodule EngHub.Repo.Migrations.CreateFileVersions do
  use Ecto.Migration

  def change do
    create table(:file_versions) do
      add :version_number, :integer
      add :storage_path, :string
      add :file_id, references(:files, on_delete: :nothing)
      add :created_by_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:file_versions, [:file_id])
    create index(:file_versions, [:created_by_id])
  end
end

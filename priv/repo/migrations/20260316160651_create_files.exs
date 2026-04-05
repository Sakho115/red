defmodule EngHub.Repo.Migrations.CreateFiles do
  use Ecto.Migration

  def change do
    create table(:files) do
      add :filename, :string
      add :storage_path, :string
      add :mime_type, :string
      add :size, :integer
      add :project_id, references(:projects, on_delete: :nothing)
      add :uploader_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:files, [:project_id])
    create index(:files, [:uploader_id])
  end
end

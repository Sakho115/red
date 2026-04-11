defmodule EngHub.Repo.Migrations.AddProjectIdToListingsAndHackathons do
  use Ecto.Migration

  def change do
    alter table(:listings) do
      add :project_id, references(:projects, on_delete: :nothing)
    end

    alter table(:hackathons) do
      add :project_id, references(:projects, on_delete: :nothing)
    end

    create index(:listings, [:project_id])
    create index(:hackathons, [:project_id])
  end
end

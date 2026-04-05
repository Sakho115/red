defmodule EngHub.Repo.Migrations.CreateProjectMembers do
  use Ecto.Migration

  def change do
    create table(:project_members) do
      add :role, :string
      add :project_id, references(:projects, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:project_members, [:project_id])
    create index(:project_members, [:user_id])
  end
end

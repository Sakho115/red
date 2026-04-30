defmodule EngHub.Repo.Migrations.CreateActivities do
  use Ecto.Migration

  def change do
    create table(:activities, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :server_id, references(:servers, on_delete: :delete_all, type: :binary_id)
      add :project_id, references(:projects, on_delete: :delete_all, type: :binary_id)
      add :action_type, :string, null: false
      add :metadata, :map, default: %{}

      timestamps(type: :utc_datetime)
    end

    create index(:activities, [:user_id])
    create index(:activities, [:server_id])
    create index(:activities, [:project_id])
    create index(:activities, [:action_type])
  end
end

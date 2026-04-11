defmodule EngHub.Repo.Migrations.CreateWorkspaceMembers do
  use Ecto.Migration

  def change do
    create table(:server_members, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :server_id, references(:servers, on_delete: :delete_all, type: :binary_id), null: false

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false
      # owner, admin, member
      add :role, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:server_members, [:server_id])
    create index(:server_members, [:user_id])
    create unique_index(:server_members, [:server_id, :user_id])
  end
end

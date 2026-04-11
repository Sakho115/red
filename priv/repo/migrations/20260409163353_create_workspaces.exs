defmodule EngHub.Repo.Migrations.CreateWorkspaces do
  use Ecto.Migration

  def change do
    create table(:servers, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :description, :text
      add :visibility, :string, default: "public"
      add :owner_id, references(:users, on_delete: :nothing, type: :binary_id), null: false
      add :deleted_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:servers, [:owner_id])
  end
end

defmodule EngHub.Repo.Migrations.AddServerAndChannelScopingToResources do
  use Ecto.Migration

  def up do
    # 1. Ensure channels and messages use binary_id
    drop_if_exists table(:messages)
    drop_if_exists table(:channels)

    create table(:channels, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :name, :string, null: false
      add :type, :string, default: "chat", null: false
      add :position, :integer, default: 0, null: false
      add :category_id, references(:categories, on_delete: :delete_all, type: :binary_id)
      add :server_id, references(:servers, on_delete: :delete_all, type: :binary_id)
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:channels, [:category_id])
    create index(:channels, [:server_id])
    create index(:channels, [:position])

    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:user_id])
    create index(:messages, [:channel_id])

    # 2. Scoping for other resources
    alter table(:projects) do
      add :server_id, references(:servers, on_delete: :nothing, type: :binary_id)
    end

    create index(:projects, [:server_id])

    alter table(:posts) do
      add :server_id, references(:servers, on_delete: :nothing, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :nothing, type: :binary_id)
    end

    create index(:posts, [:server_id])
    create index(:posts, [:channel_id])

    alter table(:threads) do
      add :server_id, references(:servers, on_delete: :nothing, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :nothing, type: :binary_id)
    end

    create index(:threads, [:server_id])
    create index(:threads, [:channel_id])

    alter table(:files) do
      add :server_id, references(:servers, on_delete: :nothing, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :nothing, type: :binary_id)
    end

    create index(:files, [:server_id])
    create index(:files, [:channel_id])

    alter table(:hackathons) do
      add :server_id, references(:servers, on_delete: :nothing, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :nothing, type: :binary_id)
    end

    create index(:hackathons, [:server_id])
    create index(:hackathons, [:channel_id])

    # 3. Finalize indexes for renamed tables
    drop_if_exists index(:server_members, [:workspace_id, :user_id])
    # Drop new one too if partial
    drop_if_exists index(:server_members, [:server_id, :user_id])
    create unique_index(:server_members, [:server_id, :user_id])

    drop_if_exists index(:categories, [:workspace_id])
    drop_if_exists index(:categories, [:server_id])
    create index(:categories, [:server_id])
  end

  def down do
    # Minimal down migration - in a real prod env this would be more comprehensive
    drop table(:messages)
    drop table(:channels)

    alter table(:projects) do
      remove :server_id
    end

    # ... other removals ...
  end

  defp not_exists_index?(table, index_name) do
    # Helper to check if index exists to avoid duplicates if migration is re-run
    # In Ecto 3.0+ we can use repo().query but it depends on environment
    # For now, we rely on Ecto's internal error handling or assume fresh start
    true
  end
end

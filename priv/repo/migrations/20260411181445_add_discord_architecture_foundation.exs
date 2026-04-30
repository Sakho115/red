defmodule EngHub.Repo.Migrations.AddDiscordArchitectureFoundation do
  use Ecto.Migration

  def change do
    # Roles
    create table(:roles, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :server_id, references(:servers, on_delete: :delete_all, type: :binary_id)
      add :name, :string, null: false
      add :color, :string
      add :position, :integer, default: 0
      add :hoist, :boolean, default: false
      add :mentionable, :boolean, default: false
      add :permissions, :bigint, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:roles, [:server_id])

    # User Roles (Join table for Server members and Roles)
    create table(:server_member_roles, primary_key: false) do
      add :server_member_id, references(:server_members, on_delete: :delete_all, type: :binary_id)
      add :role_id, references(:roles, on_delete: :delete_all, type: :binary_id)
    end

    create unique_index(:server_member_roles, [:server_member_id, :role_id])

    # Channel Overrides
    create table(:channel_overrides, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :channel_id, references(:channels, on_delete: :delete_all, type: :binary_id)
      # "role" or "member"
      add :type, :string, null: false
      # role_id or user_id
      add :target_id, :binary_id, null: false
      add :allow, :bigint, default: 0
      add :deny, :bigint, default: 0

      timestamps(type: :utc_datetime)
    end

    create index(:channel_overrides, [:channel_id])
    create unique_index(:channel_overrides, [:channel_id, :target_id])

    # Message Enhancements
    alter table(:messages) do
      add :parent_id, references(:messages, on_delete: :nothing, type: :binary_id)
      add :type, :string, default: "default"
      add :edited_at, :utc_datetime
    end

    create index(:messages, [:parent_id])

    # Reactions
    create table(:reactions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :message_id, references(:messages, on_delete: :delete_all, type: :binary_id)
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :emoji, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:reactions, [:message_id])
    create unique_index(:reactions, [:message_id, :user_id, :emoji])
  end
end

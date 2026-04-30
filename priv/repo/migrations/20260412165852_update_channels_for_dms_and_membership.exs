defmodule EngHub.Repo.Migrations.UpdateChannelsForDmsAndMembership do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      modify :server_id, :binary_id, null: true
    end

    create table(:channel_members, primary_key: false) do
      add :id, :binary_id, primary_key: true

      add :channel_id, references(:channels, on_delete: :delete_all, type: :binary_id),
        null: false

      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:channel_members, [:channel_id])
    create index(:channel_members, [:user_id])
    create unique_index(:channel_members, [:channel_id, :user_id])
  end
end

defmodule EngHub.Repo.Migrations.CreateFriendships do
  use Ecto.Migration

  def change do
    create table(:friendships, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :user_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :friend_id, references(:users, on_delete: :delete_all, type: :binary_id)
      # pending_sent, pending_received, friends, blocked
      add :status, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:friendships, [:user_id])
    create index(:friendships, [:friend_id])
    create unique_index(:friendships, [:user_id, :friend_id])
  end
end

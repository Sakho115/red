defmodule EngHub.Repo.Migrations.CreateInvites do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :server_id, references(:servers, on_delete: :delete_all, type: :binary_id)
      add :inviter_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :code, :string, null: false
      add :max_uses, :integer
      add :uses, :integer, default: 0
      add :expires_at, :utc_datetime

      timestamps(type: :utc_datetime)
    end

    create index(:invites, [:server_id])
    create index(:invites, [:inviter_id])
    create unique_index(:invites, [:code])
  end
end

defmodule EngHub.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:user_id])
    create index(:messages, [:channel_id])
  end
end

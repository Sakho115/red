defmodule EngHub.Repo.Migrations.UpdateChannelsForWorkspaces do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add :type, :string, default: "chat", null: false
      add :category_id, references(:categories, on_delete: :delete_all, type: :binary_id)
      add :server_id, references(:servers, on_delete: :delete_all, type: :binary_id)
      # We removed the modify :project_id line because it is already a bigint and nullable
    end

    create index(:channels, [:category_id])
    create index(:channels, [:server_id])
  end
end

defmodule EngHub.Repo.Migrations.AddSettingsToUsersAndServers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :settings, :map, default: %{}
    end

    alter table(:servers) do
      add :settings, :map, default: %{}
    end
  end
end

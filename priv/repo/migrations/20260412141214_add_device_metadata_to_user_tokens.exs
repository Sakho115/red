defmodule EngHub.Repo.Migrations.AddDeviceMetadataToUserTokens do
  use Ecto.Migration

  def change do
    alter table(:user_tokens) do
      add :device_name, :string
      add :user_agent, :text
      add :ip_address, :string
    end
  end
end

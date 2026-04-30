defmodule EngHub.Repo.Migrations.AddMetadataToProjects do
  use Ecto.Migration

  def change do
    alter table(:projects) do
      add :metadata, :map, default: %{}
    end
  end
end

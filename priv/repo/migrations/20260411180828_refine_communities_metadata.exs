defmodule EngHub.Repo.Migrations.RefineCommunitiesMetadata do
  use Ecto.Migration

  def change do
    alter table(:channels) do
      add :topic, :text
    end

    alter table(:categories) do
      add :description, :text
      add :emoji, :string
    end
  end
end

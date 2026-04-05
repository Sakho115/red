defmodule EngHub.Repo.Migrations.AddEngineeringFieldsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :reputation_score, :integer, default: 0
      add :contribution_level, :string, default: "Beginner"
    end
  end
end

defmodule EngHub.Repo.Migrations.AddQaFeaturesToDiscussions do
  use Ecto.Migration

  def change do
    alter table(:threads) do
      add :type, :string, default: "discussion"
    end

    alter table(:comments) do
      add :is_solution, :boolean, default: false
    end
  end
end

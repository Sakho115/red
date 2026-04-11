defmodule EngHub.Repo.Migrations.AddUniqueProjectMemberConstraint do
  use Ecto.Migration

  def change do
    create unique_index(:project_members, [:project_id, :user_id])
  end
end

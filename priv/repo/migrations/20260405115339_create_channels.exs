defmodule EngHub.Repo.Migrations.CreateChannels do
  use Ecto.Migration

  def change do
    create table(:channels) do
      add :name, :string
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:channels, [:project_id])
  end
end

defmodule EngHub.Repo.Migrations.CreateHackathons do
  use Ecto.Migration

  def change do
    create table(:hackathons) do
      add :title, :string
      add :start_date, :utc_datetime
      add :end_date, :utc_datetime

      timestamps(type: :utc_datetime)
    end
  end
end

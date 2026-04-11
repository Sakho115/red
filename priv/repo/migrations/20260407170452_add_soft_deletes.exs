defmodule EngHub.Repo.Migrations.AddSoftDeletes do
  use Ecto.Migration

  def change do
    alter table(:posts) do
      add :deleted_at, :utc_datetime
    end

    alter table(:projects) do
      add :deleted_at, :utc_datetime
    end

    alter table(:files) do
      add :deleted_at, :utc_datetime
    end
  end
end

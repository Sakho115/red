defmodule EngHub.Repo.Migrations.AddIpfsFieldsToFiles do
  use Ecto.Migration

  def change do
    alter table(:files) do
      add :cid, :string
      add :metadata, :map, default: %{}
    end

    create index(:files, [:cid])
  end
end

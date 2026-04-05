defmodule EngHub.Repo.Migrations.CreateThreads do
  use Ecto.Migration

  def change do
    create table(:threads) do
      add :category, :string
      add :title, :string
      add :content, :text
      add :author_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:threads, [:author_id])
    create index(:threads, [:project_id])
  end
end

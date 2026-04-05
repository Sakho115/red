defmodule EngHub.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :content, :text
      add :thread_id, references(:threads, on_delete: :nothing)
      add :author_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:thread_id])
    create index(:comments, [:author_id])
  end
end

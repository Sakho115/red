defmodule EngHub.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :body, :text
      add :code_snippet, :text
      add :github_url, :string
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:posts, [:user_id])
  end
end

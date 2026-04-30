defmodule EngHub.Repo.Migrations.StandardizeResourceIdsToUlid do
  use Ecto.Migration

  def up do
    # Recreate all project-related and social resources with ULID primary keys

    # Drop all dependent tables first
    execute "DROP TABLE IF EXISTS comments CASCADE"
    execute "DROP TABLE IF EXISTS file_versions CASCADE"
    execute "DROP TABLE IF EXISTS posts CASCADE"
    execute "DROP TABLE IF EXISTS messages CASCADE"
    execute "DROP TABLE IF EXISTS files CASCADE"
    execute "DROP TABLE IF EXISTS threads CASCADE"
    execute "DROP TABLE IF EXISTS hackathons CASCADE"
    execute "DROP TABLE IF EXISTS listings CASCADE"
    execute "DROP TABLE IF EXISTS project_members CASCADE"
    execute "DROP TABLE IF EXISTS follows CASCADE"

    create table(:project_members, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :role, :string, default: "viewer"
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:project_members, [:project_id])
    create index(:project_members, [:user_id])

    create table(:posts, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :body, :text, null: false
      add :code_snippet, :text
      add :github_url, :string
      add :deleted_at, :utc_datetime
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :server_id, references(:servers, on_delete: :nothing, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:posts, [:user_id])
    create index(:posts, [:server_id])
    create index(:posts, [:channel_id])

    create table(:files, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :filename, :string, null: false
      add :storage_path, :string, null: false
      add :mime_type, :string
      add :size, :integer
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
      add :server_id, references(:servers, on_delete: :nothing, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :nothing, type: :binary_id)
      add :uploader_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:files, [:project_id])
    create index(:files, [:server_id])
    create index(:files, [:channel_id])

    create table(:file_versions, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :version_number, :integer
      add :storage_path, :string
      add :file_id, references(:files, on_delete: :delete_all, type: :binary_id)
      add :created_by_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:file_versions, [:file_id])

    create table(:threads, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :content, :text
      add :category, :string
      add :author_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
      add :server_id, references(:servers, on_delete: :nothing, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:threads, [:author_id])
    create index(:threads, [:project_id])
    create index(:threads, [:server_id])
    create index(:threads, [:channel_id])

    create table(:comments, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text
      add :thread_id, references(:threads, on_delete: :delete_all, type: :binary_id)
      add :author_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:thread_id])
    create index(:comments, [:author_id])

    create table(:hackathons, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :start_date, :utc_datetime
      add :end_date, :utc_datetime
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
      add :server_id, references(:servers, on_delete: :nothing, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:hackathons, [:project_id])
    create index(:hackathons, [:server_id])
    create index(:hackathons, [:channel_id])

    create table(:listings, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :description, :text
      add :price_or_exchange, :string
      add :status, :string, default: "active"
      add :project_id, references(:projects, on_delete: :nothing, type: :binary_id)
      add :seller_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:listings, [:project_id])
    create index(:listings, [:seller_id])

    create table(:messages, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :content, :text, null: false
      add :user_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :channel_id, references(:channels, on_delete: :nothing, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:user_id])
    create index(:messages, [:channel_id])

    create table(:follows, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :follower_id, references(:users, on_delete: :delete_all, type: :binary_id)
      add :following_id, references(:users, on_delete: :delete_all, type: :binary_id)

      timestamps(type: :utc_datetime)
    end

    create index(:follows, [:follower_id])
    create index(:follows, [:following_id])
    create unique_index(:follows, [:follower_id, :following_id])
  end

  def down do
    raise "Irreversible migration"
  end
end

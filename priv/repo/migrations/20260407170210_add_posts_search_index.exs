defmodule EngHub.Repo.Migrations.AddPostsSearchIndex do
  use Ecto.Migration

  def up do
    execute(
      "CREATE INDEX posts_search_idx ON posts USING GIN (to_tsvector('english', coalesce(body, '')))"
    )
  end

  def down do
    execute("DROP INDEX posts_search_idx")
  end
end

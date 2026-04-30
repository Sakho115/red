defmodule EngHub.Repo.Migrations.AddSearchIndexes do
  use Ecto.Migration

  def up do
    execute "CREATE INDEX messages_content_idx ON messages USING GIN (to_tsvector('english', content))"
    execute "CREATE INDEX posts_body_idx ON posts USING GIN (to_tsvector('english', body))"

    execute "CREATE INDEX threads_search_idx ON threads USING GIN (to_tsvector('english', title || ' ' || content))"
  end

  def down do
    execute "DROP INDEX messages_content_idx"
    execute "DROP INDEX posts_body_idx"
    execute "DROP INDEX threads_search_idx"
  end
end

defmodule EngHub.Search do
  @moduledoc """
  The Search context for full-text search.
  """
  import Ecto.Query, warn: false
  alias EngHub.Repo
  alias EngHub.Messaging.Message
  alias EngHub.Timeline.Post
  alias EngHub.Discussions.Thread

  @doc """
  Searches messages in a server.
  """
  def search_messages(search_query, server_id) do
    from(m in Message,
      join: ch in assoc(m, :channel),
      where: ch.server_id == ^server_id,
      where:
        fragment(
          "to_tsvector('english', content) @@ plainto_tsquery('english', ?)",
          ^search_query
        ),
      order_by: [desc: m.inserted_at],
      preload: [:user, :channel],
      limit: 20
    )
    |> Repo.all()
  end

  @doc """
  Searches posts in a server.
  """
  def search_posts(search_query, server_id) do
    from(p in Post,
      where: p.server_id == ^server_id,
      where:
        fragment("to_tsvector('english', body) @@ plainto_tsquery('english', ?)", ^search_query),
      order_by: [desc: p.inserted_at],
      preload: [:user, :channel],
      limit: 20
    )
    |> Repo.all()
  end

  @doc """
  Searches threads in a server.
  """
  def search_threads(search_query, server_id) do
    from(t in Thread,
      where: t.server_id == ^server_id,
      where:
        fragment(
          "to_tsvector('english', title || ' ' || content) @@ plainto_tsquery('english', ?)",
          ^search_query
        ),
      order_by: [desc: t.inserted_at],
      limit: 20
    )
    |> Repo.all()
  end
end

defmodule EngHub.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias EngHub.Repo

  alias EngHub.Timeline.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts(opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)
    offset = Keyword.get(opts, :offset, 0)

    cache_key = "timeline_global_#{limit}_#{offset}"

    EngHub.Cache.get_or_fetch(cache_key, 60, fn ->
      from(p in Post,
        where: is_nil(p.deleted_at),
        order_by: [desc: p.inserted_at],
        preload: [:user],
        limit: ^limit,
        offset: ^offset
      )
      |> Repo.all()
    end)
  end

  @doc """
  Returns the list of posts for a specific channel.
  """
  def list_posts_by_channel(channel_id) do
    from(p in Post,
      where: p.channel_id == ^channel_id and is_nil(p.deleted_at),
      order_by: [desc: p.inserted_at],
      preload: [:user]
    )
    |> Repo.all()
  end

  @doc """
  Returns the list of posts for the user's feed, ordered by newest first.
  Accepts optional `:limit` and `:offset` for pagination.
  """
  def list_feed_posts(user_id, opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)
    offset = Keyword.get(opts, :offset, 0)

    from(p in Post,
      where:
        is_nil(p.deleted_at) and
          (p.user_id == ^user_id or
             p.user_id in subquery(
               from(f in EngHub.Social.Follow,
                 where: f.follower_id == ^user_id,
                 select: f.following_id
               )
             )),
      order_by: [desc: p.inserted_at],
      limit: ^limit,
      offset: ^offset,
      preload: [:user]
    )
    |> Repo.all()
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id) do
    from(p in Post, where: p.id == ^id and is_nil(p.deleted_at))
    |> Repo.one!()
  end

  def subscribe do
    Phoenix.PubSub.subscribe(EngHub.PubSub, "posts")
  end

  defp broadcast({:ok, post}, event) do
    Phoenix.PubSub.broadcast(EngHub.PubSub, "posts", {event, post})
    {:ok, post}
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(attrs) do
    result =
      %Post{}
      |> Post.changeset(attrs)
      |> Repo.insert()
      |> broadcast(:post_created)

    if match?({:ok, _}, result) do
      EngHub.Cache.invalidate_prefix("timeline_global_")
      :telemetry.execute([:eng_hub, :timeline, :post_created], %{count: 1})
    end

    result
  end

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs) do
    result =
      post
      |> Post.changeset(attrs)
      |> Repo.update()
      |> broadcast(:post_updated)

    if match?({:ok, _}, result) do
      EngHub.Cache.invalidate_prefix("timeline_global_")
    end

    result
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    result =
      post
      |> Ecto.Changeset.change(%{deleted_at: DateTime.truncate(DateTime.utc_now(), :second)})
      |> Repo.update()

    case result do
      {:ok, updated_post} ->
        broadcast({:ok, updated_post}, :post_deleted)
        EngHub.Cache.invalidate_prefix("timeline_global_")
        :telemetry.execute([:eng_hub, :timeline, :post_deleted], %{count: 1})
        {:ok, updated_post}

      error ->
        error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  @doc """
  Performs a full-text search on posts using PostgreSQL tsvector.
  """
  def search_posts(query) when is_binary(query) and query != "" do
    formatted_query = String.replace(query, " ", " | ")

    from(p in Post,
      where:
        is_nil(p.deleted_at) and
          fragment(
            "to_tsvector('english', coalesce(body, '')) @@ to_tsquery('english', ?)",
            ^formatted_query
          ),
      order_by: [
        # Order by rank
        desc:
          fragment(
            "ts_rank(to_tsvector('english', coalesce(body, '')), to_tsquery('english', ?))",
            ^formatted_query
          )
      ],
      preload: [:user]
    )
    |> Repo.all()
  end

  def search_posts(_empty_query), do: list_posts()
end

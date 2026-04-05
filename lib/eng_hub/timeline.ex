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

    Post
    |> order_by([p], desc: p.inserted_at)
    |> preload([p], :user)
    |> limit(^limit)
    |> offset(^offset)
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
        p.user_id == ^user_id or
          p.user_id in subquery(
            from(f in EngHub.Social.Follow,
              where: f.follower_id == ^user_id,
              select: f.following_id
            )
          ),
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
  def get_post!(id), do: Repo.get!(Post, id)

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
    post
    |> Post.changeset(attrs)
    |> Repo.update()
    |> broadcast(:post_updated)
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
      Repo.delete(post)
      |> broadcast(:post_deleted)
      
    if match?({:ok, _}, result) do
      :telemetry.execute([:eng_hub, :timeline, :post_deleted], %{count: 1})
    end
    
    result
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
end

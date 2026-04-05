defmodule EngHubWeb.PostLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Timeline
  import Ecto.Query

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Posts
        <:actions>
          <.button variant="primary" navigate={~p"/posts/new"}>
            <.icon name="hero-plus" /> New Post
          </.button>
        </:actions>
      </.header>

      <div id="posts" phx-update="stream" class="space-y-6 mt-6">
        <div :for={{dom_id, post} <- @streams.posts} id={dom_id} class="bg-base-100 shadow rounded-lg p-6 flex flex-col gap-4">
          <div class="flex justify-between items-center text-sm text-gray-500">
            <div class="flex items-center gap-4">
              <span class="font-medium text-base-content">{post.user.email}</span>
              <span :if={post.user_id != @current_user.id}>
                <button :if={MapSet.member?(@following_ids, post.user_id)} phx-click="unfollow" phx-value-id={post.user_id} class="text-xs text-primary hover:underline">Unfollow</button>
                <button :if={not MapSet.member?(@following_ids, post.user_id)} phx-click="follow" phx-value-id={post.user_id} class="text-xs text-primary font-semibold hover:underline">Follow</button>
              </span>
            </div>
            <div class="flex gap-2">
              <.link navigate={~p"/posts/#{post}"} class="hover:text-primary">Show</.link>
              <.link :if={post.user_id == @current_user.id} navigate={~p"/posts/#{post}/edit"} class="hover:text-primary">Edit</.link>
              <.link :if={post.user_id == @current_user.id} phx-click={JS.push("delete", value: %{id: post.id}) |> hide("##{dom_id}")} data-confirm="Delete this post?" class="hover:text-error">Delete</.link>
            </div>
          </div>
          <p class="text-base-content whitespace-pre-wrap">{post.body}</p>
          
          <div :if={post.code_snippet && post.code_snippet != ""} class="bg-gray-900 rounded-lg overflow-hidden text-sm relative" phx-hook="Highlight" id={"code-#{dom_id}"}>
            <pre><code class="language-elixir p-4 block">{post.code_snippet}</code></pre>
          </div>

          <div :if={post.github_url && post.github_url != ""} class="text-sm">
            <.icon name="hero-link" class="inline-block" /> <a href={post.github_url} target="_blank" class="text-primary hover:underline">{post.github_url}</a>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Timeline.subscribe()

    current_user_id = socket.assigns.current_user.id
    
    following_ids = 
      EngHub.Repo.all(
        from f in EngHub.Social.Follow, 
        where: f.follower_id == ^current_user_id, 
        select: f.following_id
      )
      |> MapSet.new()

    {:ok,
     socket
     |> assign(:page_title, "Feed")
     |> assign(:following_ids, following_ids)
     |> stream(:posts, Timeline.list_feed_posts(current_user_id))}
  end

  @impl true
  def handle_info({:post_created, post}, socket) do
    if post.user_id == socket.assigns.current_user.id || MapSet.member?(socket.assigns.following_ids, post.user_id) do
      post = EngHub.Repo.preload(post, :user)
      {:noreply, stream_insert(socket, :posts, post, at: 0)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    if post.user_id == socket.assigns.current_user.id || MapSet.member?(socket.assigns.following_ids, post.user_id) do
      post = EngHub.Repo.preload(post, :user)
      {:noreply, stream_insert(socket, :posts, post)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:post_deleted, post}, socket) do
    {:noreply, stream_delete(socket, :posts, post)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    post = Timeline.get_post!(id)
    {:ok, _} = Timeline.delete_post(post)

    {:noreply, socket}
  end

  @impl true
  def handle_event("follow", %{"id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    EngHub.Social.follow_user(user_id, id)
    
    following_ids = MapSet.put(socket.assigns.following_ids, id)
    
    {:noreply, 
     socket 
     |> assign(:following_ids, following_ids)
     |> stream(:posts, Timeline.list_feed_posts(user_id), reset: true)}
  end
  
  @impl true
  def handle_event("unfollow", %{"id" => id}, socket) do
    user_id = socket.assigns.current_user.id
    EngHub.Social.unfollow_user(user_id, id)
    
    following_ids = MapSet.delete(socket.assigns.following_ids, id)
    
    {:noreply, 
     socket 
     |> assign(:following_ids, following_ids)
     |> stream(:posts, Timeline.list_feed_posts(user_id), reset: true)}
  end
end

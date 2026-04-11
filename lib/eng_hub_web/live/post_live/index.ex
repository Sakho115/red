defmodule EngHubWeb.PostLive.Index do
  use EngHubWeb, :live_view

  alias EngHub.Timeline
  import Ecto.Query

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_user}>
      <div class="p-8 max-w-4xl mx-auto">
        <header class="flex items-center justify-between mb-12">
          <div>
            <h1 class="text-4xl font-black text-white italic tracking-tighter uppercase">Engineering Feed</h1>
            <p class="text-white/40 font-medium">Real-time updates from your engineering network.</p>
          </div>
          <.button variant="primary" navigate={~p"/posts/new"} class="shadow-xl shadow-primary/20">
            <.icon name="hero-plus" /> New Post
          </.button>
        </header>

        <div id="posts" phx-update="stream" class="space-y-8">
          <div
            :for={{dom_id, post} <- @streams.posts}
            id={dom_id}
            class="bg-white/5 border border-white/5 backdrop-blur-xl rounded-[32px] p-8 flex flex-col gap-6 hover:bg-white/[0.07] transition-all group"
          >
            <div class="flex justify-between items-start">
              <div class="flex items-center gap-4">
                <div class="w-12 h-12 rounded-2xl bg-primary/20 flex items-center justify-center text-primary font-black shadow-inner shadow-white/10 group-hover:scale-110 transition-transform">
                  {String.at(post.user.email, 0) |> String.upcase()}
                </div>
                <div>
                  <div class="font-black text-white italic truncate tracking-tight">{post.user.email |> String.split("@") |> List.first()}</div>
                  <div class="text-[10px] font-black text-white/20 uppercase tracking-widest">{Calendar.strftime(post.inserted_at, "%b %d, %Y")}</div>
                </div>
                <div :if={post.user_id != @current_user.id} class="ml-2">
                  <button
                    :if={MapSet.member?(@following_ids, post.user_id)}
                    phx-click="unfollow"
                    phx-value-id={post.user_id}
                    class="px-3 py-1 rounded-full bg-white/5 text-[10px] font-black uppercase text-primary border border-primary/20 hover:bg-primary/10 transition-all"
                  >
                    Following
                  </button>
                  <button
                    :if={not MapSet.member?(@following_ids, post.user_id)}
                    phx-click="follow"
                    phx-value-id={post.user_id}
                    class="px-4 py-1.5 rounded-full bg-primary text-[10px] font-black uppercase text-white shadow-lg shadow-primary/20 hover:scale-105 transition-all"
                  >
                    Follow
                  </button>
                </div>
              </div>
              <div class="flex gap-2 opacity-0 group-hover:opacity-100 transition-opacity">
                <.link navigate={~p"/posts/#{post}"} class="p-2 bg-white/5 rounded-lg text-white/40 hover:text-white transition-colors"><.icon name="hero-eye" class="w-4 h-4" /></.link>
                <.link
                  :if={post.user_id == @current_user.id}
                  navigate={~p"/posts/#{post}/edit"}
                  class="p-2 bg-white/5 rounded-lg text-white/40 hover:text-white transition-colors"
                >
                  <.icon name="hero-pencil-square" class="w-4 h-4" />
                </.link>
                <.link
                  :if={post.user_id == @current_user.id}
                  phx-click={JS.push("delete", value: %{id: post.id}) |> hide("##{dom_id}")}
                  data-confirm="Delete this post?"
                  class="p-2 bg-white/5 rounded-lg text-white/40 hover:text-error transition-colors"
                >
                  <.icon name="hero-trash" class="w-4 h-4" />
                </.link>
              </div>
            </div>
            
            <p class="text-[16px] text-white/80 leading-relaxed font-medium">{post.body}</p>

            <div
              :if={post.code_snippet && post.code_snippet != ""}
              class="bg-black/40 rounded-2xl overflow-hidden text-sm relative border border-white/5"
              phx-hook="Highlight"
              id={"code-#{dom_id}"}
            >
              <pre><code class="language-elixir p-6 block">{post.code_snippet}</code></pre>
            </div>

            <div :if={post.github_url && post.github_url != ""} class="flex items-center gap-2 px-4 py-3 bg-white/5 rounded-xl border border-white/5 w-fit">
              <.icon name="hero-link" class="w-4 h-4 text-primary" />
              <a href={post.github_url} target="_blank" class="text-xs font-bold text-primary hover:underline truncate max-w-xs">
                {post.github_url}
              </a>
            </div>
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
    if post.user_id == socket.assigns.current_user.id ||
         MapSet.member?(socket.assigns.following_ids, post.user_id) do
      post = EngHub.Repo.preload(post, :user)
      {:noreply, stream_insert(socket, :posts, post, at: 0)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_info({:post_updated, post}, socket) do
    if post.user_id == socket.assigns.current_user.id ||
         MapSet.member?(socket.assigns.following_ids, post.user_id) do
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

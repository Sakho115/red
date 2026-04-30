defmodule EngHubWeb.SkeletonComponents do
  use Phoenix.Component

  @doc """
  Renders a skeleton loader for the chat container.
  """
  def chat_skeleton(assigns) do
    ~H"""
    <div class="w-full space-y-6 animate-pulse p-4">
      <%= for i <- 1..6 do %>
        <div class="flex items-start gap-4">
          <div class="w-10 h-10 bg-white/5 rounded-[12px] shrink-0 shimmer"></div>
          <div class="flex-1 space-y-2 py-1">
            <div class="flex items-center gap-2">
              <div class="h-3 bg-white/10 rounded w-24 shimmer"></div>
              <div class="h-2 bg-white/5 rounded w-16 shimmer"></div>
            </div>
            <div class={[
              "h-4 bg-white/5 rounded shimmer",
              rem(i, 2) == 0 && "w-3/4",
              rem(i, 3) == 0 && "w-1/2",
              rem(i, 5) == 0 && "w-5/6"
            ]}>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a skeleton loader for the channel list.
  """
  def channel_list_skeleton(assigns) do
    ~H"""
    <div class="space-y-4 animate-pulse px-2 py-4">
      <div class="h-3 bg-white/5 rounded w-20 mx-2 mb-4 shimmer"></div>
      <%= for i <- 1..8 do %>
        <div class="flex items-center gap-2 px-2 py-1.5">
          <div class="w-4 h-4 bg-white/5 rounded shrink-0 shimmer"></div>
          <div class={[
            "h-3 bg-white/5 rounded shimmer",
            rem(i, 2) == 0 && "w-24",
            rem(i, 2) != 0 && "w-32"
          ]}>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a skeleton loader for the member list.
  """
  def member_list_skeleton(assigns) do
    ~H"""
    <div class="space-y-4 animate-pulse px-2 py-4">
      <div class="h-3 bg-white/5 rounded w-24 mx-2 mb-4 shimmer"></div>
      <%= for _ <- 1..10 do %>
        <div class="flex items-center gap-2.5 px-2 py-1.5">
          <div class="w-8 h-8 bg-white/5 rounded-[8px] shrink-0 shimmer"></div>
          <div class="space-y-1.5 flex-1">
            <div class="h-3 bg-white/10 rounded w-20 shimmer"></div>
            <div class="h-2 bg-white/5 rounded w-12 shimmer"></div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a skeleton loader for server icons.
  """
  def server_list_skeleton(assigns) do
    ~H"""
    <div class="space-y-3 animate-pulse px-2 py-3 flex flex-col items-center">
      <%= for _ <- 1..5 do %>
        <div class="w-12 h-12 bg-white/5 rounded-[24px] shimmer"></div>
      <% end %>
    </div>
    """
  end
end

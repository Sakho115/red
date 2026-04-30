defmodule EngHubWeb.DiscoveryLive.Index do
  use EngHubWeb, :live_view
  import EngHubWeb.PlaceholderComponents

  @impl true
  def render(assigns) do
    ~H"""
    <.list_placeholder title="Server Discovery" type="grid" />
    """
  end
end

defmodule EngHubWeb.DiscoveryLive.Explore do
  use EngHubWeb, :live_view
  import EngHubWeb.PlaceholderComponents

  @impl true
  def render(assigns) do
    ~H"""
    <.list_placeholder title="Explore Engineering Communities" type="grid" />
    """
  end
end

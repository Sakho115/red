defmodule PluggableTestHelper do
  import Phoenix.LiveViewTest

  def get_child(parent_live, id) do
    # How to get a child live view?
    # In LiveView > 0.17, live_children(parent_live) returns a list of views?
    # Actually, we can just use live_isolated if that fails.
  end
end

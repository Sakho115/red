defmodule EngHub.Projects.RBAC.UnauthorizedError do
  @moduledoc "Raised when a user attempts an action they don't have the role for."
  defexception [:message]

  @impl true
  def message(%{message: msg}), do: msg
end

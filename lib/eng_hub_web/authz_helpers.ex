defmodule EngHubWeb.AuthzHelpers do
  @moduledoc """
  Helpers for performing authorization checks within LiveView events.
  """
  import Phoenix.LiveView
  alias EngHub.Authz

  @doc """
  Authorizes a user action and returns the socket.
  If unauthorized, it puts a flash message and redirects.
  """
  def authorize_action(socket, action, target) do
    user = socket.assigns.current_user

    case Authz.authorize(user, action, target) do
      :ok ->
        socket

      {:error, :unauthorized} ->
        socket
        |> put_flash(:error, "Access Denied: You do not have permission for this.")
        |> push_navigate(to: "/")
    end
  end

  @doc """
  Boolean check for use in templates.
  """
  def can?(user, action, target) do
    Authz.can?(user, action, target)
  end
end

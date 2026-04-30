defmodule EngHub.Authz do
  @moduledoc """
  The Authz context handles RBAC and policy-based authorization.
  """
  import Bitwise

  alias EngHub.Communities.ServerMember

  # Permissions Bitmask Constants
  @permissions %{
    view_channels: 1 <<< 0,
    manage_channels: 1 <<< 1,
    manage_roles: 1 <<< 2,
    manage_server: 1 <<< 3,
    create_invites: 1 <<< 4,
    send_messages: 1 <<< 5,
    attach_files: 1 <<< 6,
    administrator: 1 <<< 30
  }

  @doc """
  Returns the map of all defined permissions and their bit values.
  """
  def all_permissions, do: @permissions

  @doc """
  Checks if a user can perform an action on a target.
  """
  def can?(user, action, target) do
    case authorize(user, action, target) do
      :ok -> true
      _ -> false
    end
  end

  @doc """
  Authorizes a user action on a target. Returns `:ok` or `{:error, :unauthorized}`.
  """
  def authorize(user, :manage_server, %EngHub.Communities.Server{} = server) do
    case get_member(server.id, user.id) do
      %{role: "owner"} ->
        :ok

      %{permissions: perms} ->
        if has_permission?(perms, :manage_server) or has_permission?(perms, :administrator),
          do: :ok,
          else: {:error, :unauthorized}

      nil ->
        {:error, :unauthorized}
    end
  end

  def authorize(user, :manage_channel, %EngHub.Communities.Channel{} = channel) do
    authorize(user, :manage_channels, %EngHub.Communities.Server{id: channel.server_id})
  end

  def authorize(user, :manage_channels, %EngHub.Communities.Server{} = server) do
    case get_member(server.id, user.id) do
      %{role: "owner"} ->
        :ok

      %{role: "admin"} ->
        :ok

      %{permissions: perms} ->
        if has_permission?(perms, :manage_channels) or has_permission?(perms, :administrator),
          do: :ok,
          else: {:error, :unauthorized}

      nil ->
        {:error, :unauthorized}
    end
  end

  def authorize(_user, :send_message, %EngHub.Communities.Channel{} = _channel) do
    # Default behavior for now, can be refined with channel-level overrides
    :ok
  end

  # Default fallback
  def authorize(_user, _action, _target), do: {:error, :unauthorized}

  @doc """
  Checks if a permission bitmask contains a specific permission.
  """
  def has_permission?(mask, permission_name) when is_atom(permission_name) do
    bit = Map.get(@permissions, permission_name, 0)
    (mask &&& bit) == bit
  end

  defp get_member(server_id, user_id) do
    # In a real app, this would use a preload or cache
    EngHub.Repo.get_by(ServerMember, server_id: server_id, user_id: user_id)
  end
end

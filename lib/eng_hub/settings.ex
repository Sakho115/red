defmodule EngHub.Settings do
  @moduledoc """
  The Settings context handles user and server preferences.
  """
  alias EngHub.Repo
  alias EngHub.Identity.User
  alias EngHub.Communities.Server

  @doc """
  Updates user settings.
  """
  def update_user_settings(%User{} = user, attrs) do
    user
    |> User.changeset(%{settings: Map.merge(user.settings || %{}, attrs)})
    |> Repo.update()
  end

  @doc """
  Gets a specific user setting.
  """
  def get_user_setting(%User{} = user, key, default \\ nil) do
    Map.get(user.settings || %{}, to_string(key), default)
  end

  @doc """
  Updates server settings.
  """
  def update_server_settings(%Server{} = server, attrs) do
    server
    |> Server.changeset(%{settings: Map.merge(server.settings || %{}, attrs)})
    |> Repo.update()
  end

  @doc """
  Gets a specific server setting.
  """
  def get_server_setting(%Server{} = server, key, default \\ nil) do
    Map.get(server.settings || %{}, to_string(key), default)
  end
end

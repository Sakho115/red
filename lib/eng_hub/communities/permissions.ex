defmodule EngHub.Communities.Permissions do
  @moduledoc """
  Bitwise permission constants for Discord-fidelity architecture.
  """

  import Bitwise

  # Server Permissions
  def create_instant_invite, do: 1 <<< 0
  def kick_members, do: 1 <<< 1
  def ban_members, do: 1 <<< 2
  def administrator, do: 1 <<< 3
  def manage_channels, do: 1 <<< 4
  def manage_server, do: 1 <<< 5
  def change_nickname, do: 1 <<< 6
  def manage_nicknames, do: 1 <<< 7
  def manage_roles, do: 1 <<< 8
  def manage_webhooks, do: 1 <<< 9

  # Text Permissions
  def view_channel, do: 1 <<< 10
  def send_messages, do: 1 <<< 11
  def manage_messages, do: 1 <<< 12
  def add_reactions, do: 1 <<< 13
  def use_external_emojis, do: 1 <<< 14
  def mention_everyone, do: 1 <<< 15
  def read_message_history, do: 1 <<< 16

  # Voice Permissions
  def connect, do: 1 <<< 17
  def speak, do: 1 <<< 18
  def mute_members, do: 1 <<< 19
  def deafen_members, do: 1 <<< 20
  def move_members, do: 1 <<< 21
  def use_vad, do: 1 <<< 22

  # Presets
  def all_permissions do
    Enum.reduce(
      [
        create_instant_invite(),
        kick_members(),
        ban_members(),
        administrator(),
        manage_channels(),
        manage_server(),
        change_nickname(),
        manage_nicknames(),
        manage_roles(),
        manage_webhooks(),
        view_channel(),
        send_messages(),
        manage_messages(),
        add_reactions(),
        use_external_emojis(),
        mention_everyone(),
        read_message_history(),
        connect(),
        speak(),
        mute_members(),
        deafen_members(),
        move_members(),
        use_vad()
      ],
      0,
      fn p, acc -> acc ||| p end
    )
  end

  def default_permissions do
    view_channel() ||| send_messages() ||| read_message_history() ||| add_reactions() |||
      connect() ||| speak()
  end

  def has_permission?(user_permissions, permission) do
    (user_permissions &&& administrator()) != 0 or (user_permissions &&& permission) != 0
  end
end

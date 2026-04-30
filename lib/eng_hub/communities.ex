defmodule EngHub.Communities do
  @moduledoc """
  The Communities context for managing Servers, Categories, and Channels.
  """

  import Ecto.Query, warn: false
  alias EngHub.Repo

  alias EngHub.Communities.Server
  alias EngHub.Communities.Category
  alias EngHub.Communities.ServerMember
  alias EngHub.Communities.Channel
  alias EngHub.Communities.ChannelMember
  alias EngHub.Communities.Role
  alias EngHub.Communities.ChannelPermissionOverride
  alias EngHub.Communities.Permissions

  # Servers

  def list_servers do
    Repo.all(from s in Server, where: is_nil(s.deleted_at), order_by: [asc: s.name])
  end

  def list_user_servers(user_id) do
    from(s in Server,
      join: m in ServerMember,
      on: m.server_id == s.id,
      where: m.user_id == ^user_id and is_nil(s.deleted_at),
      order_by: [asc: s.name]
    )
    |> Repo.all()
  end

  def list_servers_for_user(user_id), do: list_user_servers(user_id)

  def get_server!(id), do: Repo.get!(Server, id)

  def get_server(id) do
    case Repo.get(Server, id) do
      nil -> {:error, :not_found}
      server -> {:ok, server}
    end
  end

  def get_server_tree(server_id) do
    server = Repo.get!(Server, server_id)

    categories =
      from(c in Category,
        where: c.server_id == ^server_id,
        order_by: [asc: c.position],
        preload: [channels: ^from(ch in Channel, order_by: [asc: ch.position, asc: ch.name])]
      )
      |> Repo.all()

    {server, categories}
  end

  def create_server(attrs, owner_id) do
    Repo.transaction(fn ->
      case %Server{owner_id: owner_id} |> Server.changeset(attrs) |> Repo.insert() do
        {:ok, server} ->
          # Add owner as server member
          {:ok, _} =
            create_server_member(%{
              server_id: server.id,
              user_id: owner_id,
              role: "owner"
            })

          # Create @everyone role
          {:ok, _everyone} =
            create_role(%{
              server_id: server.id,
              name: "@everyone",
              permissions: Permissions.default_permissions(),
              position: 0
            })

          # Create default structure
          # 1. GENERAL
          {:ok, general} =
            create_category(%{
              server_id: server.id,
              name: "General",
              emoji: "📢",
              position: 0
            })

          create_channel(%{
            server_id: server.id,
            category_id: general.id,
            name: "announcements",
            type: :general_chat,
            topic: "Official updates and team announcements",
            position: 0
          })

          create_channel(%{
            server_id: server.id,
            category_id: general.id,
            name: "general",
            type: :general_chat,
            topic: "General team discussion and watercooler",
            position: 1
          })

          # 2. ENGINEERING
          {:ok, engineering} =
            create_category(%{
              server_id: server.id,
              name: "Engineering",
              emoji: "🛠️",
              position: 1
            })

          create_channel(%{
            server_id: server.id,
            category_id: engineering.id,
            name: "projects",
            type: :project,
            topic: "Active engineering projects and workspaces",
            position: 0
          })

          create_channel(%{
            server_id: server.id,
            category_id: engineering.id,
            name: "technical-talk",
            type: :threads,
            topic: "Deep-dive technical discussions and Q&A",
            position: 1
          })

          # 3. RESOURCES
          {:ok, resources} =
            create_category(%{
              server_id: server.id,
              name: "Resources",
              emoji: "📚",
              position: 2
            })

          create_channel(%{
            server_id: server.id,
            category_id: resources.id,
            name: "docs",
            type: :files,
            topic: "Project documentation, assets, and shared resources",
            position: 0
          })

          create_channel(%{
            server_id: server.id,
            category_id: resources.id,
            name: "showcase",
            type: :posts,
            topic: "Share your progress and project reveals!",
            position: 1
          })

          server

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  def update_server(%Server{} = server, attrs) do
    server
    |> Server.changeset(attrs)
    |> Repo.update()
  end

  def change_server(%Server{} = server, attrs \\ %{}) do
    Server.changeset(server, attrs)
  end

  @doc """
  Returns a list of servers where both user_a and user_b are members.
  """
  def get_mutual_servers(user_a_id, user_b_id) do
    query =
      from s in Server,
        join: m1 in ServerMember,
        on: m1.server_id == s.id,
        join: m2 in ServerMember,
        on: m2.server_id == s.id,
        where: m1.user_id == ^user_a_id and m2.user_id == ^user_b_id,
        select: s

    Repo.all(query)
  end

  alias EngHub.Communities.Invite

  @doc """
  Generates a new invite for a server.
  """
  def create_invite(server_id, inviter_id, attrs \\ %{}) do
    code =
      attrs[:code] ||
        :crypto.strong_rand_bytes(6)
        |> Base.url_encode64()
        |> String.replace(~r/[^a-zA-Z0-9]/, "")

    %Invite{}
    |> Invite.changeset(
      Map.merge(attrs, %{server_id: server_id, inviter_id: inviter_id, code: code})
    )
    |> Repo.insert()
  end

  @doc """
  Uses an invite code to join a server.
  """
  def use_invite(code, user_id) do
    Repo.transaction(fn ->
      case Repo.get_by(Invite, code: code) |> Repo.preload(:server) do
        nil ->
          Repo.rollback(:not_found)

        invite ->
          cond do
            invite.expires_at && DateTime.compare(DateTime.utc_now(), invite.expires_at) == :gt ->
              Repo.rollback(:expired)

            invite.max_uses && invite.uses >= invite.max_uses ->
              Repo.rollback(:full)

            true ->
              # 1. Increment uses
              invite |> Invite.changeset(%{uses: invite.uses + 1}) |> Repo.update!()

              # 2. Add member to server
              case join_server(invite.server_id, user_id) do
                {:ok, _member} -> {:ok, invite.server}
                {:error, reason} -> Repo.rollback(reason)
              end
          end
      end
    end)
  end

  def delete_server(%Server{} = server) do
    # Soft delete
    server
    |> Server.changeset(%{deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  # Authorization

  def can_manage_server?(user, server) do
    member = get_server_member(server.id, user.id)
    # Check for legacy owner/admin roles OR new bitwise permission
    (member && member.role in ["owner", "admin"]) or
      has_permission?(member, server.id, nil, Permissions.manage_server())
  end

  def can_manage_channels?(user, server) do
    member = get_server_member(server.id, user.id)

    (member && member.role in ["owner", "admin"]) or
      has_permission?(member, server.id, nil, Permissions.manage_channels())
  end

  def can_write_in_channel?(user, channel) do
    member = get_server_member(channel.server_id, user.id)

    (member && member.role in ["owner", "admin"]) or
      has_permission?(member, channel.server_id, channel.id, Permissions.send_messages())
  end

  def has_permission?(nil, _server_id, _channel_id, _permission), do: false

  def has_permission?(%ServerMember{} = member, server_id, channel_id, permission) do
    perms = get_effective_permissions(member, server_id, channel_id)
    Permissions.has_permission?(perms, permission)
  end

  def get_effective_permissions(member, server_id, channel_id \\ nil) do
    # 1. Base permissions from @everyone role
    everyone_role = get_role_by_name(server_id, "@everyone")
    base_permissions = (everyone_role && everyone_role.permissions) || 0

    # 2. Add permissions from all user roles
    member = Repo.preload(member, :roles)

    role_permissions =
      Enum.reduce(member.roles, base_permissions, fn role, acc ->
        acc |> Bitwise.bor(role.permissions)
      end)

    # 3. Apply channel overrides if channel_id provided
    if channel_id do
      overrides = list_channel_overrides(channel_id)

      # a. @everyone override
      everyone_override = Enum.find(overrides, &(&1.target_id == everyone_role.id))
      role_permissions = apply_override(role_permissions, everyone_override)

      # b. Role overrides
      role_ids = Enum.map(member.roles, & &1.id)
      role_overrides = Enum.filter(overrides, &(&1.type == :role and &1.target_id in role_ids))

      {allow, deny} =
        Enum.reduce(role_overrides, {0, 0}, fn ov, {a, d} ->
          {a |> Bitwise.bor(ov.allow), d |> Bitwise.bor(ov.deny)}
        end)

      role_permissions =
        role_permissions |> Bitwise.band(Bitwise.bnot(deny)) |> Bitwise.bor(allow)

      # c. Member override
      member_override =
        Enum.find(overrides, &(&1.type == :member and &1.target_id == member.user_id))

      apply_override(role_permissions, member_override)
    else
      role_permissions
    end
  end

  defp apply_override(permissions, nil), do: permissions

  defp apply_override(permissions, override) do
    permissions |> Bitwise.band(Bitwise.bnot(override.deny)) |> Bitwise.bor(override.allow)
  end

  def get_role_by_name(server_id, name) do
    Repo.one(from r in Role, where: r.server_id == ^server_id and r.name == ^name)
  end

  def list_channel_overrides(channel_id) do
    Repo.all(from o in ChannelPermissionOverride, where: o.channel_id == ^channel_id)
  end

  # Categories

  def create_category(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  # Channels

  def create_channel(attrs) do
    Repo.transaction(fn ->
      case %Channel{} |> Channel.changeset(attrs) |> Repo.insert() do
        {:ok, channel} ->
          # Post-creation logic based on type
          case channel.type do
            :project ->
              # Auto-create a project for the channel if not linked
              unless attrs["project_id"] do
                {:ok, project} =
                  EngHub.Projects.create_project(%{
                    "name" => channel.name,
                    "description" => "Project workspace for ##{channel.name}",
                    "server_id" => channel.server_id
                  })

                channel |> Channel.changeset(%{project_id: project.id}) |> Repo.update!()
              else
                channel
              end

            _ ->
              channel
          end
          |> broadcast_channel_change(:channel_created)
          |> case do
            {:ok, channel} -> channel
            channel -> channel
          end

        {:error, changeset} ->
          Repo.rollback(changeset)
      end
    end)
  end

  def update_channel(%Channel{} = channel, attrs) do
    channel
    |> Channel.changeset(attrs)
    |> Repo.update()
    |> broadcast_channel_change(:channel_updated)
  end

  def delete_channel(%Channel{} = channel) do
    Repo.delete(channel)
    |> broadcast_channel_change(:channel_deleted)
  end

  def get_or_create_dm_channel(user_a_id, user_b_id) do
    # Try to find existing DM. Since a DM between A and B has exactly those two members,
    # we can find a channel of type :dm where both are members.
    query =
      from c in Channel,
        join: cm1 in ChannelMember,
        on: cm1.channel_id == c.id,
        join: cm2 in ChannelMember,
        on: cm2.channel_id == c.id,
        where: c.type == :dm and cm1.user_id == ^user_a_id and cm2.user_id == ^user_b_id,
        limit: 1

    case Repo.one(query) do
      %Channel{} = channel ->
        {:ok, channel}

      nil ->
        Repo.transaction(fn ->
          # Create DM channel (no server_id)
          {:ok, channel} = create_channel(%{type: :dm, name: "dm"})

          # Add members
          Repo.insert_all(ChannelMember, [
            %{
              id: Ecto.ULID.generate(),
              channel_id: channel.id,
              user_id: user_a_id,
              inserted_at: NaiveDateTime.utc_now(),
              updated_at: NaiveDateTime.utc_now()
            },
            %{
              id: Ecto.ULID.generate(),
              channel_id: channel.id,
              user_id: user_b_id,
              inserted_at: NaiveDateTime.utc_now(),
              updated_at: NaiveDateTime.utc_now()
            }
          ])

          channel
        end)
    end
  end

  def list_dm_channels(user_id) do
    from(c in Channel,
      join: cm in ChannelMember,
      on: cm.channel_id == c.id,
      where: c.type == :dm and cm.user_id == ^user_id,
      preload: [:members]
    )
    |> Repo.all()
  end

  defp broadcast_channel_change({:ok, channel} = result, event) do
    broadcast_to_targets(channel, event)
    result
  end

  defp broadcast_channel_change(%Channel{} = channel, event) do
    broadcast_to_targets(channel, event)
    {:ok, channel}
  end

  defp broadcast_channel_change(result, _), do: result

  defp broadcast_to_targets(%Channel{type: :dm} = channel, event) do
    # For DMs, broadcast to its members
    channel = Repo.preload(channel, :members)

    Enum.each(channel.members || [], fn member ->
      Phoenix.PubSub.broadcast(
        EngHub.PubSub,
        "user:#{member.user_id}",
        {__MODULE__, event, channel}
      )
    end)
  end

  defp broadcast_to_targets(%Channel{} = channel, event) do
    if channel.server_id do
      Phoenix.PubSub.broadcast(
        EngHub.PubSub,
        "server:#{channel.server_id}",
        {__MODULE__, event, channel}
      )
    end
  end

  # Roles

  def create_role(attrs) do
    %Role{}
    |> Role.changeset(attrs)
    |> Repo.insert()
  end

  def update_role(%Role{} = role, attrs) do
    role
    |> Role.changeset(attrs)
    |> Repo.update()
  end

  def delete_role(%Role{} = role) do
    Repo.delete(role)
  end

  def list_roles(server_id) do
    Repo.all(from r in Role, where: r.server_id == ^server_id, order_by: [asc: r.position])
  end

  def add_role_to_member(member_id, role_id) do
    Repo.insert_all("server_member_roles", [[server_member_id: member_id, role_id: role_id]],
      on_conflict: :nothing
    )
  end

  # Channel Overrides

  def create_channel_override(attrs) do
    %ChannelPermissionOverride{}
    |> ChannelPermissionOverride.changeset(attrs)
    |> Repo.insert()
  end

  def create_server_member(attrs) do
    %ServerMember{}
    |> ServerMember.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Adds a user to a server with a default role.
  """
  def join_server(server_id, user_id) do
    case get_server_member(server_id, user_id) do
      nil ->
        create_server_member(%{server_id: server_id, user_id: user_id, role: "member"})

      member ->
        {:ok, member}
    end
  end

  def get_server_member(server_id, user_id) do
    Repo.one(from m in ServerMember, where: m.server_id == ^server_id and m.user_id == ^user_id)
  end

  def list_server_members(server_id) do
    from(m in ServerMember,
      where: m.server_id == ^server_id,
      preload: [:user, :roles],
      order_by: [asc: m.inserted_at]
    )
    |> Repo.all()
  end

  # Ordering logic

  def reorder_categories(server_id, category_ids) do
    Repo.transaction(fn ->
      category_ids
      |> Enum.with_index()
      |> Enum.each(fn {id, index} ->
        from(c in Category, where: c.id == ^id and c.server_id == ^server_id)
        |> Repo.update_all(set: [position: index])
      end)
    end)
  end

  def reorder_channels(category_id, channel_ids) do
    Repo.transaction(fn ->
      channel_ids
      |> Enum.with_index()
      |> Enum.each(fn {id, index} ->
        from(c in Channel, where: c.id == ^id and c.category_id == ^category_id)
        |> Repo.update_all(set: [position: index])
      end)
    end)
  end
end

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

  def get_server!(id), do: Repo.get!(Server, id)

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

          # Create default category and general chat
          {:ok, category} =
            create_category(%{
              server_id: server.id,
              name: "Information",
              position: 0
            })

          {:ok, _} =
            create_channel(%{
              server_id: server.id,
              category_id: category.id,
              name: "general",
              type: :general_chat,
              position: 0
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

  def delete_server(%Server{} = server) do
    # Soft delete
    server
    |> Server.changeset(%{deleted_at: DateTime.utc_now()})
    |> Repo.update()
  end

  # Authorization

  def can_manage_server?(user, server) do
    member = get_server_member(server.id, user.id)
    member && member.role in ["owner", "admin"]
  end

  def can_manage_channels?(user, server) do
    can_manage_server?(user, server)
  end

  def can_write_in_channel?(user, channel) do
    member = get_server_member(channel.server_id, user.id)
    member && member.role in ["owner", "admin", "member"]
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

  defp broadcast_channel_change({:ok, channel} = result, event) do
    Phoenix.PubSub.broadcast(
      EngHub.PubSub,
      "server:#{channel.server_id}",
      {__MODULE__, event, channel}
    )

    result
  end

  defp broadcast_channel_change(%Channel{} = channel, event) do
    # For transaction success cases that return the struct
    Phoenix.PubSub.broadcast(
      EngHub.PubSub,
      "server:#{channel.server_id}",
      {__MODULE__, event, channel}
    )

    {:ok, channel}
  end

  defp broadcast_channel_change(result, _), do: result

  # Server Members

  def create_server_member(attrs) do
    %ServerMember{}
    |> ServerMember.changeset(attrs)
    |> Repo.insert()
  end

  def get_server_member(server_id, user_id) do
    Repo.one(from m in ServerMember, where: m.server_id == ^server_id and m.user_id == ^user_id)
  end

  def list_server_members(server_id) do
    from(m in ServerMember,
      where: m.server_id == ^server_id,
      preload: [:user],
      order_by: [asc: m.role, asc: m.inserted_at]
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

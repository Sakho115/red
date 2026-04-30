defmodule EngHub.Notifications do
  @moduledoc """
  The Notifications context.
  """
  import Ecto.Query, warn: false
  alias EngHub.Repo
  alias EngHub.Notifications.Notification

  @doc """
  Returns the list of notifications for a user.
  """
  def list_notifications(user_id) do
    Repo.all(
      from n in Notification,
        where: n.user_id == ^user_id,
        order_by: [desc: n.inserted_at],
        limit: 50
    )
  end

  @doc """
  Gets the count of unread notifications for a user.
  """
  def get_unread_count(user_id) do
    Repo.one(
      from n in Notification,
        where: n.user_id == ^user_id and is_nil(n.read_at),
        select: count(n.id)
    )
  end

  @doc """
  Creates a notification and broadcasts it via PubSub.
  """
  def notify(user_id, title, body, type, metadata \\ %{}) do
    attrs = %{
      user_id: user_id,
      title: title,
      body: body,
      type: type,
      metadata: metadata
    }

    %Notification{}
    |> Notification.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:notification_created)
  end

  @doc """
  Marks a notification as read.
  """
  def mark_as_read(notification_id) do
    case Repo.get(Notification, notification_id) do
      nil ->
        {:error, :not_found}

      notification ->
        notification
        |> Notification.changeset(%{read_at: DateTime.utc_now()})
        |> Repo.update()
        |> broadcast(:notification_updated)
    end
  end

  @doc """
  Marks all notifications as read for a user.
  """
  def mark_all_as_read(user_id) do
    from(n in Notification, where: n.user_id == ^user_id and is_nil(n.read_at))
    |> Repo.update_all(set: [read_at: DateTime.utc_now(), updated_at: DateTime.utc_now()])

    Phoenix.PubSub.broadcast(EngHub.PubSub, "notifications:#{user_id}", :notifications_cleared)
  end

  defp broadcast({:ok, notification} = result, event) do
    Phoenix.PubSub.broadcast(
      EngHub.PubSub,
      "notifications:#{notification.user_id}",
      {__MODULE__, event, notification}
    )

    result
  end

  defp broadcast(result, _), do: result

  @doc """
  Subscribes the caller to a user's notifications.
  """
  def subscribe(user_id) do
    Phoenix.PubSub.subscribe(EngHub.PubSub, "notifications:#{user_id}")
  end
end

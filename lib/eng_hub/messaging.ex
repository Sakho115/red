defmodule EngHub.Messaging do
  @moduledoc """
  The Messaging context.
  """

  import Ecto.Query, warn: false
  alias EngHub.Repo

  alias EngHub.Communities.Channel
  alias EngHub.Messaging.Message
  alias EngHub.Messaging.Reaction

  def subscribe(channel_id) do
    Phoenix.PubSub.subscribe(EngHub.PubSub, "channels:#{channel_id}")
  end

  defp broadcast({:ok, %Message{} = message}, event) do
    preloaded = Repo.preload(message, [:user, [parent: :user], reactions: :user])

    Phoenix.PubSub.broadcast(
      EngHub.PubSub,
      "channels:#{message.channel_id}",
      {__MODULE__, event, preloaded}
    )

    {:ok, message}
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  @doc """
  Returns the list of channels.

  ## Examples

      iex> list_channels()
      [%Channel{}, ...]

  """
  def list_channels do
    Repo.all(Channel)
  end

  @doc """
  Gets a single channel.

  Raises `Ecto.NoResultsError` if the Channel does not exist.

  ## Examples

      iex> get_channel!(123)
      %Channel{}

      iex> get_channel!(456)
      ** (Ecto.NoResultsError)

  """
  def get_channel!(id), do: Repo.get!(Channel, id)

  @doc """
  Creates a channel.

  ## Examples

      iex> create_channel(%{field: value})
      {:ok, %Channel{}}

      iex> create_channel(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_channel(attrs) do
    %Channel{}
    |> Channel.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a channel.

  ## Examples

      iex> update_channel(channel, %{field: new_value})
      {:ok, %Channel{}}

      iex> update_channel(channel, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_channel(%Channel{} = channel, attrs) do
    channel
    |> Channel.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a channel.

  ## Examples

      iex> delete_channel(channel)
      {:ok, %Channel{}}

      iex> delete_channel(channel)
      {:error, %Ecto.Changeset{}}

  """
  def delete_channel(%Channel{} = channel) do
    Repo.delete(channel)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking channel changes.

  ## Examples

      iex> change_channel(channel)
      %Ecto.Changeset{data: %Channel{}}

  """
  def change_channel(%Channel{} = channel, attrs \\ %{}) do
    Channel.changeset(channel, attrs)
  end

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages do
    Repo.all(Message)
  end

  def list_messages_by_channel(channel_id) do
    Message
    |> where(channel_id: ^channel_id)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
    |> Repo.preload([:user, [parent: :user], reactions: :user])
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(attrs) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert()
    |> broadcast(:message_created)
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
    |> broadcast(:message_updated)
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
    |> broadcast(:message_deleted)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  # Reactions

  def create_reaction(attrs) do
    %Reaction{}
    |> Reaction.changeset(attrs)
    |> Repo.insert()
    |> broadcast_reaction(:reaction_created)
  end

  def delete_reaction(message_id, user_id, emoji) do
    from(r in Reaction,
      where: r.message_id == ^message_id and r.user_id == ^user_id and r.emoji == ^emoji
    )
    |> Repo.delete_all()
    |> broadcast_reaction_deleted(message_id)
  end

  def toggle_reaction(message_id, user_id, emoji) do
    query =
      from(r in Reaction,
        where: r.message_id == ^message_id and r.user_id == ^user_id and r.emoji == ^emoji
      )

    case Repo.one(query) do
      %Reaction{} -> delete_reaction(message_id, user_id, emoji)
      nil -> create_reaction(%{message_id: message_id, user_id: user_id, emoji: emoji})
    end
  end

  defp broadcast_reaction({:ok, reaction}, event) do
    case Repo.get(Message, reaction.message_id) do
      %Message{channel_id: channel_id} ->
        Phoenix.PubSub.broadcast(
          EngHub.PubSub,
          "channels:#{channel_id}",
          {__MODULE__, event, reaction}
        )

      nil ->
        # Message was likely deleted simultaneously
        :ok
    end

    {:ok, reaction}
  end

  defp broadcast_reaction(error, _), do: error

  defp broadcast_reaction_deleted({n, _}, message_id) when n > 0 do
    case Repo.get(Message, message_id) do
      %Message{channel_id: channel_id} ->
        Phoenix.PubSub.broadcast(
          EngHub.PubSub,
          "channels:#{channel_id}",
          {__MODULE__, :reaction_deleted, %{message_id: message_id}}
        )

      nil ->
        # Message was likely deleted
        :ok
    end
  end

  defp broadcast_reaction_deleted(result, _), do: result
end

defmodule EngHub.Discussions.Thread do
  use Ecto.Schema
  import Ecto.Changeset

  schema "threads" do
    field :category, :string
    field :title, :string
    field :content, :string
    field :author_id, Ecto.ULID
    field :project_id, :id
    belongs_to :server, EngHub.Communities.Server, type: :binary_id
    belongs_to :channel, EngHub.Communities.Channel, type: :binary_id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(thread, attrs) do
    thread
    |> cast(attrs, [:category, :title, :content, :project_id, :author_id, :server_id, :channel_id])
    |> validate_required([:category, :title, :content, :author_id])
  end
end

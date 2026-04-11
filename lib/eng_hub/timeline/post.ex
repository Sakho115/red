defmodule EngHub.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field :body, :string
    field :code_snippet, :string
    field :github_url, :string
    field :deleted_at, :utc_datetime
    belongs_to :user, EngHub.Identity.User, type: Ecto.ULID
    belongs_to :server, EngHub.Communities.Server, type: Ecto.ULID
    belongs_to :channel, EngHub.Communities.Channel, type: Ecto.ULID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:body, :code_snippet, :github_url, :user_id, :server_id, :channel_id])
    |> validate_required([:body, :code_snippet, :github_url, :user_id])
    |> validate_length(:body, max: 2000)
  end
end

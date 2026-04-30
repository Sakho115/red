defmodule EngHub.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "posts" do
    field :body, :string
    field :code_snippet, :string
    field :github_url, :string
    field :deleted_at, :utc_datetime
    belongs_to :user, EngHub.Identity.User
    belongs_to :server, EngHub.Communities.Server
    belongs_to :channel, EngHub.Communities.Channel

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

defmodule EngHub.Identity.User do
  @moduledoc """
  Schema representing a user of the application.

  ## Considerations

  - Ecto.ULID is used to prevent user enumeration attacks while maintaining sortability.
    - Spec: https://github.com/ulid/spec
    - Context: https://www.honeybadger.io/blog/uuids-and-ulids/
    - UUIDv7 may provide the same functionality, but it is not fully supported as of 09/2023.
  - Email confirmation is not implemented.
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias EngHub.Identity.UserKey
  alias EngHub.Identity.UserToken

  @type t :: %__MODULE__{
          id: binary(),
          email: String.t(),
          inserted_at: NaiveDateTime.t(),
          updated_at: NaiveDateTime.t()
        }

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "users" do
    field :email, :string
    field :username, :string
    field :bio, :string
    field :website, :string
    field :avatar_url, :string

    field :reputation_score, :integer, default: 0
    field :contribution_level, :string, default: "Beginner"
    has_many :keys, UserKey, preload_order: [desc: :last_used_at]
    has_many :tokens, UserToken, preload_order: [desc: :inserted_at]

    has_many :posts, EngHub.Timeline.Post
    has_many :follower_relationships, EngHub.Social.Follow, foreign_key: :following_id
    has_many :followers, through: [:follower_relationships, :follower]
    has_many :following_relationships, EngHub.Social.Follow, foreign_key: :follower_id
    has_many :following, through: [:following_relationships, :following]

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    fields = __MODULE__.__schema__(:fields)

    user
    |> cast(attrs, fields)
    |> validate_required([:email, :username])
    |> validate_length(:email, min: 6, max: 120)
    |> validate_length(:username, min: 3, max: 20)
    |> validate_format(:username, ~r/^[a-zA-Z0-9_]+$/, message: "can only contain letters, numbers, and underscores")
    |> validate_format(:email, ~r/@/)
    |> update_change(:email, &String.downcase/1)
    |> unique_constraint(:email)
    |> unique_constraint(:username)
    |> cast_assoc(:keys)
    |> cast_assoc(:tokens)
  end
end

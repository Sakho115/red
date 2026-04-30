defmodule EngHub.Communities.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "categories" do
    field :name, :string
    field :description, :string
    field :emoji, :string
    field :position, :integer, default: 0

    belongs_to :server, EngHub.Communities.Server
    has_many :channels, EngHub.Communities.Channel

    timestamps(type: :utc_datetime)
  end

  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name, :position, :server_id, :description, :emoji])
    |> validate_required([:name, :server_id])
  end
end

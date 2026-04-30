defmodule EngHub.Discussions.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, Ecto.ULID, autogenerate: true}
  @foreign_key_type Ecto.ULID
  schema "comments" do
    field :content, :string
    field :is_solution, :boolean, default: false
    belongs_to :thread, EngHub.Discussions.Thread
    belongs_to :author, EngHub.Identity.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :is_solution])
    |> validate_required([:content])
  end
end

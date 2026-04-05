defmodule EngHub.Discussions.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string
    field :thread_id, :id
    field :author_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end
end

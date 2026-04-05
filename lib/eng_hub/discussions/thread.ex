defmodule EngHub.Discussions.Thread do
  use Ecto.Schema
  import Ecto.Changeset

  schema "threads" do
    field :category, :string
    field :title, :string
    field :content, :string
    field :author_id, :id
    field :project_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(thread, attrs) do
    thread
    |> cast(attrs, [:category, :title, :content])
    |> validate_required([:category, :title, :content])
  end
end

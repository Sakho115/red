defmodule EngHub.Events.Hackathon do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hackathons" do
    field :title, :string
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(hackathon, attrs) do
    hackathon
    |> cast(attrs, [:title, :start_date, :end_date])
    |> validate_required([:title, :start_date, :end_date])
  end
end

defmodule EngHub.Repo do
  use Ecto.Repo,
    otp_app: :eng_hub,
    adapter: Ecto.Adapters.Postgres
end

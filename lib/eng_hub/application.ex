defmodule EngHub.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Start the rate limit table owned by the application so it survives
    :ets.new(:eng_hub_rate_limit, [
      :set,
      :public,
      :named_table,
      read_concurrency: true,
      write_concurrency: true
    ])

    children = [
      EngHubWeb.Telemetry,
      EngHub.Repo,
      {EngHub.UserTokenCleaner, interval_minutes: 10},
      {DNSCluster, query: Application.get_env(:eng_hub, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: EngHub.PubSub},
      EngHubWeb.Presence,
      EngHub.Cache,
      {Oban, Application.fetch_env!(:eng_hub, Oban)},
      # Start a worker by calling: EngHub.Worker.start_link(arg)
      # {EngHub.Worker, arg},
      # Start to serve requests, typically the last entry
      EngHubWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EngHub.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EngHubWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

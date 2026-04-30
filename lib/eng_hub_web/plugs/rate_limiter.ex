defmodule EngHubWeb.Plugs.RateLimiter do
  @moduledoc """
  A production-grade Rate-Limiting plug that uses the Identity context.
  Restricts brute-force attempts on sensitive endpoints.
  """
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]
  alias EngHub.Identity

  @limit 5
  @window_ms 15 * 60 * 1000

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.method in ["POST"] do
      ip = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")

      case Identity.check_rate_limit("ip:#{ip}", @limit, @window_ms) do
        {:ok, _count} ->
          conn

        {:error, :rate_limited} ->
          conn
          |> put_flash(:error, "Too many login attempts. Access temporarily restricted.")
          |> redirect(to: "/sign-in")
          |> halt()
      end
    else
      conn
    end
  end
end

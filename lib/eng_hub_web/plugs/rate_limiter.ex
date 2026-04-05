defmodule EngHubWeb.Plugs.RateLimiter do
  @moduledoc """
  A simple rate-Limiting plug that uses an ETS table tracking IP addresses.
  Restricts users to 5 requests per 15 minutes to prevent brute forcing OTPs.
  """
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  @table :eng_hub_rate_limit
  @limit 5
  @window_ms 15 * 60 * 1000

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.method in ["POST"] do
      ip = conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
      now = System.system_time(:millisecond)

      # Cleanup old entries manually or lazily check bounds
      case :ets.lookup(@table, ip) do
        [{^ip, count, first_hit}] when now - first_hit < @window_ms ->
          if count >= @limit do
            conn
            |> put_flash(:error, "Too many login attempts. Please try again later.")
            |> redirect(to: "/sign-in")
            |> halt()
          else
            :ets.insert(@table, {ip, count + 1, first_hit})
            conn
          end

        # Expired or doesn't exist
        _ ->
          :ets.insert(@table, {ip, 1, now})
          conn
      end
    else
      conn
    end
  end
end

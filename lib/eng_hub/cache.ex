defmodule EngHub.Cache do
  @moduledoc """
  A generic ETS-backed caching GenServer for highly accessed data.
  """
  use GenServer

  @table :eng_hub_cache

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def get(key) do
    case :ets.lookup(@table, key) do
      [{^key, value, expires_at}] ->
        # Check TTL
        if System.system_time(:second) < expires_at do
          {:ok, value}
        else
          :ets.delete(@table, key)
          :miss
        end

      [] ->
        :miss
    end
  end

  def put(key, value, ttl_seconds \\ 300) do
    expires_at = System.system_time(:second) + ttl_seconds
    :ets.insert(@table, {key, value, expires_at})
    :ok
  end

  def delete(key) do
    :ets.delete(@table, key)
    :ok
  end

  def invalidate_prefix(prefix) do
    # Simple prefix matcher
    match_spec = [
      {{:"$1", :_, :_}, [{:==, {:binary_part, :"$1", 0, byte_size(prefix)}, prefix}], [true]}
    ]

    :ets.select_delete(@table, match_spec)
    :ok
  end

  def get_or_fetch(key, ttl_seconds \\ 300, fetch_fn) do
    case get(key) do
      {:ok, val} ->
        val

      :miss ->
        val = fetch_fn.()
        put(key, val, ttl_seconds)
        val
    end
  end

  @impl true
  def init(_) do
    :ets.new(@table, [:set, :public, :named_table, read_concurrency: true])
    {:ok, %{}}
  end
end

defmodule Firmware.DdnsUpdater do
  @moduledoc """
  Cloudflare DNS の A レコードを、現在のグローバル IPv4 に合わせて更新する GenServer。

  設定はビルド時に `firmware/.env` から取り込み、`:firmware, Firmware.DdnsUpdater` に格納する。
  """

  use GenServer
  require Logger

  @cf_api "https://api.cloudflare.com/client/v4"
  @ip_url "https://api.ipify.org"
  @boot_delay_ms 5_000

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @doc """
  次回の定期実行を待たずに、すぐに同期を実行する（IEx 向け）。
  """
  def sync_now do
    GenServer.call(__MODULE__, :sync_now, 30_000)
  end

  @impl true
  def init(_opts) do
    config = Application.get_env(:firmware, __MODULE__, [])

    state = %{
      api_token: Keyword.fetch!(config, :api_token),
      zone_name: Keyword.fetch!(config, :zone_name),
      record_name: Keyword.fetch!(config, :record_name),
      interval_ms: Keyword.fetch!(config, :interval_sec) * 1000,
      zone_id: nil,
      record_id: nil,
      proxied: false,
      ttl: 1,
      last_ip: nil
    }

    Process.send_after(self(), :tick, @boot_delay_ms)
    Logger.info("DDNS updater started for #{state.record_name} (every #{div(state.interval_ms, 1000)}s)")
    {:ok, state}
  end

  @impl true
  def handle_info(:tick, state) do
    state = do_sync(state)
    Process.send_after(self(), :tick, state.interval_ms)
    {:noreply, state}
  end

  @impl true
  def handle_call(:sync_now, _from, state) do
    state = do_sync(state)
    {:reply, {:ok, state.last_ip}, state}
  end

  defp do_sync(state) do
    with {:ok, ip} <- fetch_public_ip(),
         {:ok, state} <- ensure_record(state),
         {:ok, state} <- maybe_update(state, ip) do
      state
    else
      {:error, reason} ->
        Logger.error("DDNS sync failed: #{format_error(reason)}")
        state
    end
  end

  defp fetch_public_ip do
    case Req.get(@ip_url, receive_timeout: 15_000) do
      {:ok, %{status: 200, body: body}} when is_binary(body) ->
        ip = String.trim(body)

        if valid_ipv4?(ip) do
          {:ok, ip}
        else
          {:error, {:invalid_ip, ip}}
        end

      {:ok, %{status: status, body: body}} ->
        {:error, {:ip_http_error, status, body}}

      {:error, reason} ->
        {:error, {:ip_request_failed, reason}}
    end
  end

  defp ensure_record(%{zone_id: zone_id, record_id: record_id} = state)
       when is_binary(zone_id) and is_binary(record_id) do
    {:ok, state}
  end

  defp ensure_record(state) do
    with {:ok, zone_id} <- fetch_zone_id(state),
         {:ok, record} <- fetch_dns_record(state, zone_id) do
      {:ok,
       %{
         state
         | zone_id: zone_id,
           record_id: record["id"],
           proxied: Map.get(record, "proxied", false),
           ttl: Map.get(record, "ttl", 1),
           last_ip: record["content"]
       }}
    end
  end

  defp fetch_zone_id(state) do
    case cf_get(state, "/zones", %{name: state.zone_name, status: "active"}) do
      {:ok, [zone | _]} ->
        {:ok, zone["id"]}

      {:ok, []} ->
        {:error, {:zone_not_found, state.zone_name}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp fetch_dns_record(state, zone_id) do
    path = "/zones/#{zone_id}/dns_records"

    case cf_get(state, path, %{type: "A", name: state.record_name}) do
      {:ok, [record | _]} ->
        {:ok, record}

      {:ok, []} ->
        {:error, {:record_not_found, state.record_name}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp maybe_update(state, ip) do
    if state.last_ip == ip do
      Logger.debug("DDNS unchanged: #{state.record_name} -> #{ip}")
      {:ok, state}
    else
      update_dns_record(state, ip)
    end
  end

  defp update_dns_record(state, ip) do
    path = "/zones/#{state.zone_id}/dns_records/#{state.record_id}"

    body = %{
      type: "A",
      name: state.record_name,
      content: ip,
      ttl: state.ttl,
      proxied: state.proxied
    }

    case cf_put(state, path, body) do
      {:ok, _record} ->
        Logger.info("DDNS updated: #{state.record_name} #{state.last_ip || "(unknown)"} -> #{ip}")
        {:ok, %{state | last_ip: ip}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp cf_get(state, path, params) do
    case Req.get(cf_url(path),
           headers: cf_headers(state),
           params: params,
           receive_timeout: 15_000
         ) do
      {:ok, %{status: 200, body: %{"success" => true, "result" => result}}} ->
        {:ok, result}

      {:ok, %{status: status, body: body}} ->
        {:error, {:cf_http_error, :get, status, body}}

      {:error, reason} ->
        {:error, {:cf_request_failed, :get, reason}}
    end
  end

  defp cf_put(state, path, body) do
    case Req.put(cf_url(path),
           headers: cf_headers(state),
           json: body,
           receive_timeout: 15_000
         ) do
      {:ok, %{status: 200, body: %{"success" => true, "result" => result}}} ->
        {:ok, result}

      {:ok, %{status: status, body: body}} ->
        {:error, {:cf_http_error, :put, status, body}}

      {:error, reason} ->
        {:error, {:cf_request_failed, :put, reason}}
    end
  end

  defp cf_url(path), do: @cf_api <> path

  defp cf_headers(state) do
    [
      {"authorization", "Bearer #{state.api_token}"},
      {"content-type", "application/json"}
    ]
  end

  defp valid_ipv4?(ip) do
    case :inet.parse_address(String.to_charlist(ip)) do
      {:ok, {_, _, _, _}} -> true
      _ -> false
    end
  end

  defp format_error(reason), do: inspect(reason, limit: 200)
end

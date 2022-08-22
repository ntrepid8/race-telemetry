defmodule RacingTelemetry.F122 do
  @moduledoc """
  F1 22 Context.

  """
  require Logger
  alias RacingTelemetry.F122Supervisor
  alias RacingTelemetry.F122.Models.F122LapDataPackets
  alias RacingTelemetry.F122.Models.F122CarTelemetryPackets

  @timeout 5_000


  @doc """
  Listen for telemetry from F1 22.

  """
  def listen(opts \\ []) do
    # options
    port = Keyword.get(opts, :port) || 24134

    # listen
    init_arg = %{listen_port: port}
    RacingTelemetry.F122Supervisor.register(init_arg)
  end

  @doc """
  Starts worker and registers name in the cluster.

  ## Options

    * `listen_port`: listen for UDP packets on this port, if not provided a random port will be used

  ## Example

    iex> RacingTelemetry.F122.start_worker(1, listen_port: 24134)
    {:ok, pid}

  """
  def start_worker(user_id, opts \\ []) do
    # options
    {listen_port, opts} = Keyword.pop(opts, :listen_port, 0)

    # swarm
    swarm_name = {:f1_22_server, user_id}
    init_arg = %{
      listen_port: listen_port,
      user_id: user_id,
    }
    with {:ok, pid} <- Swarm.register_name(swarm_name, F122Supervisor, :register, [init_arg, opts], @timeout) do
      {:ok, pid}
    else
      # startup failed
      {:error, {:invalid_return, {:error, {:bad_return_value, {:error, reason}}}}} -> {:error, reason}
      # some other error
      error -> error
    end
  end

  @doc """
  Find or start and register a name in the cluster.

  """
  def fetch_or_start_worker(user_id, opts \\ []) do
    # options
    {listen_port, opts} = Keyword.pop(opts, :listen_port, 0)

    # swarm
    swarm_name = {:f1_22_server, user_id}
    init_arg = %{
      listen_port: listen_port,
      user_id: user_id,
    }
    with {:ok, pid} <- Swarm.whereis_or_register_name(swarm_name, F122Supervisor, :register, [init_arg, opts], @timeout) do
      {:ok, pid}
    else
      # startup failed
      {:error, {:invalid_return, {:error, {:bad_return_value, {:error, reason}}}}} -> {:error, reason}
      # some other error
      error -> error
    end
  end

  @doc """
  Stop a worker.

  """
  def stop_worker(user_id, opts \\ []) do
    # options
    timeout = Keyword.get(opts, :timeout) || @timeout

    # stop
    swarm_name = {:f1_22_server, user_id}
    case Swarm.whereis_name(swarm_name) do
      :undefined -> :ok
      pid -> GenServer.stop(pid, :normal, timeout)
    end
  catch
    # Normal exits are not a problem
    # This can happen when a gen_server is shutting itself down and another process also calls
    #   stop_worker/2 to ensure the gen_server actually stopped.
    :exit, {{:normal, {:sys, :terminate, [_, :normal, _]}}, {GenServer, :stop, [_, :normal, _]}} ->
      :ok

    # exit for some other reason
    # Sometimes the server shuts itself down between the call to `Swarm.whereis_name` and
    #   the call to `GenServer.stop/3`. Look for the pattern of "no process" in the warnings.
    :exit, reason ->
      Logger.warning("stop_worker: user_id=#{user_id} catch=exit reason=#{inspect reason}")
  end

  @doc """
  Fetch a list of clients the server has received data from.

  """
  def fetch_f1_22_server_udp_clients(user_id, opts \\ []) do
    timeout = Keyword.get(opts, :timeout) || @timeout
    with {:ok, pid} <- fetch_or_start_worker(user_id) do
      GenServer.call(pid, {:fetch_udp_clients, []}, timeout)
    end
  end

  @doc """
  Fetch a list of clients the server has received data from.

  """
  def fetch_f1_22_server_udp_listen_port(user_id, opts \\ []) do
    timeout = Keyword.get(opts, :timeout) || @timeout
    with {:ok, pid} <- fetch_or_start_worker(user_id) do
      GenServer.call(pid, {:fetch_udp_listen_port, []}, timeout)
    end
  end

  @doc """
  Fetch lap_data for a given user/session/lap_number/car_index.

  """
  def fetch_f1_22_lap_data(m_sessionUID, car_index, lap_number) do
    with {:ok, %{first: ld_first, last: ld_last}} <-
        F122LapDataPackets.fetch_f1_22_lap_data_packet_car_lap_first_and_last(m_sessionUID, car_index, lap_number)
    do
      lap_data = F122LapDataPackets.find_f1_22_lap_data_packet_car_lap_records(m_sessionUID, car_index, lap_number)
      car_telemetry =
        F122CarTelemetryPackets.find_f1_22_car_telemetry_packet_car_frames(
          m_sessionUID,
          car_index,
          ld_first.m_header.m_frameIdentifier,
          ld_last.m_header.m_frameIdentifier)
      # done
      {:ok, %{
        lap_data_first: ld_first,
        lap_data_last: ld_last,
        lap_data: lap_data,
        car_telemetry: car_telemetry,
      }}
    end
  end

  @doc """
  Fetch plot data for car speed (X) by lap distance (Y).

  """
  def fetch_plot_data_car_speed(m_sessionUID, car_index, lap_number) do
    with {:ok, data} <- fetch_f1_22_lap_data(m_sessionUID, car_index, lap_number) do
      plot_data =
        Enum.map(data.lap_data, fn lap_data ->
          case find_by_m_frameIdentifier(data.car_telemetry, lap_data.m_header.m_frameIdentifier) do
            nil -> nil
            car_telemetry -> %{y: car_telemetry.m_speed, x: lap_data.m_lapDistance}
          end
        end)
        |> Enum.filter(fn item -> !is_nil(item) end)

      {:ok, plot_data}
    end
  end

  defp find_by_m_frameIdentifier(items, m_frameIdentifier) do
    Enum.find(items, fn
      %{m_header: %{m_frameIdentifier: ^m_frameIdentifier}} -> true
      _not_found -> false
    end)
  end

  def fetch_car_telemetry_plot_data(m_sessionUID, car_index, lap_number) do
    with {:ok, data} <- fetch_f1_22_lap_data(m_sessionUID, car_index, lap_number) do
      # speed KPH
      speed_plot_data =
        Enum.map(data.lap_data, fn lap_data ->
          case find_by_m_frameIdentifier(data.car_telemetry, lap_data.m_header.m_frameIdentifier) do
            nil -> nil
            car_telemetry -> %{y: car_telemetry.m_speed, x: lap_data.m_lapDistance}
          end
        end)
        |> Enum.filter(fn item -> !is_nil(item) end)

      # gear
      gear_plot_data =
        Enum.map(data.lap_data, fn lap_data ->
          case find_by_m_frameIdentifier(data.car_telemetry, lap_data.m_header.m_frameIdentifier) do
            nil -> nil
            car_telemetry -> %{y: car_telemetry.m_gear, x: lap_data.m_lapDistance}
          end
        end)
        |> Enum.filter(fn item -> !is_nil(item) end)

      # steer
      steer_plot_data =
        Enum.map(data.lap_data, fn lap_data ->
          case find_by_m_frameIdentifier(data.car_telemetry, lap_data.m_header.m_frameIdentifier) do
            nil -> nil
            car_telemetry -> %{y: car_telemetry.m_steer, x: lap_data.m_lapDistance}
          end
        end)
        |> Enum.filter(fn item -> !is_nil(item) end)

      # throttle
      throttle_plot_data =
        Enum.map(data.lap_data, fn lap_data ->
          case find_by_m_frameIdentifier(data.car_telemetry, lap_data.m_header.m_frameIdentifier) do
            nil -> nil
            car_telemetry -> %{y: car_telemetry.m_throttle, x: lap_data.m_lapDistance}
          end
        end)
        |> Enum.filter(fn item -> !is_nil(item) end)

      # brake
      brake_plot_data =
        Enum.map(data.lap_data, fn lap_data ->
          case find_by_m_frameIdentifier(data.car_telemetry, lap_data.m_header.m_frameIdentifier) do
            nil -> nil
            car_telemetry -> %{y: car_telemetry.m_brake, x: lap_data.m_lapDistance}
          end
        end)
        |> Enum.filter(fn item -> !is_nil(item) end)

      # DRS
      drs_plot_data =
        Enum.map(data.lap_data, fn lap_data ->
          case find_by_m_frameIdentifier(data.car_telemetry, lap_data.m_header.m_frameIdentifier) do
            nil -> nil
            car_telemetry -> %{y: car_telemetry.m_drs, x: lap_data.m_lapDistance}
          end
        end)
        |> Enum.filter(fn item -> !is_nil(item) end)

      # done
      {:ok, %{
        speed: speed_plot_data,
        gear: gear_plot_data,
        steer: steer_plot_data,
        throttle: throttle_plot_data,
        brake: brake_plot_data,
        drs: drs_plot_data,
      }}
    end
  end

end

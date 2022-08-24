defmodule RacingTelemetry.F122 do
  @moduledoc """
  F1 22 Context.

  """
  use RacingTelemetry.Query
  require Logger
  alias RacingTelemetry, as: RT
  alias RacingTelemetry.F122Supervisor
  alias RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader

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
  Fetch a list of available F1 22 sessions.

  """
  def find_f1_22_sessions() do
    Ecto.Query.from(i in F122PacketHeader,
      where: i.packet_type == ^"car_telemetry",
      distinct: [i.m_sessionUID],
      order_by: [i.inserted_at])
    |> RT.Repo.all()
    |> Enum.map(fn i ->
      %{
        m_sessionUID: Decimal.to_integer(i.m_sessionUID),
        inserted_at: i.inserted_at,
        m_playerCarIndex: i.m_playerCarIndex,
      }
    end)
    |> Enum.sort_by(fn i -> DateTime.to_unix(i.inserted_at) end)
  end

end

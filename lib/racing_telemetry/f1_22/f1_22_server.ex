defmodule RacingTelemetry.F122Server do
  @doc """
  Receive UDP packets from an "F1 22" game.

  """
  use GenServer, restart: :temporary
  require Logger
  alias RacingTelemetry, as: RT
  alias RacingTelemetry.F122.Models.{
    F122CarTelemetryPackets,
    F122LapDataPackets,
    F122SessionPackets,
  }
  alias RacingTelemetry.F122.Packets.{
    F122Packet,
    F122PacketHeader,
    F122PacketMotionData,
    F122PacketMotionCarMotion,
    F122PacketLapData,
    F122PacketLapDataCarLapData,
    F122PacketEventData,
    F122PacketCarTelemetry,
    F122PacketSession,
  }

  defstruct [
    # config
    listen_port: 0,  # "F1" is the hex number 241 and "22" is the hex number 34
    user_id: nil,

    # runtime
    udp_clients: nil,
    listen_socket: nil,
    packet_type_samples: [],
    f1_22_packets_lap_data: [],
    f1_22_packets_car_telemetry: [],
    f1_22_packets_session: [],

    # GenServer stuff
    hibernate_timeout: 15_000,  # hibernate after 15 seconds of inactivity
  ]

  # initialization

  def start_link(init_arg, opts \\ []) do
    Logger.debug("start_link: init_arg=#{inspect init_arg} opts=#{inspect opts}")
    GenServer.start_link(__MODULE__, init_arg, opts)
  end

  def init(init_arg) do
    Logger.debug("init: init_arg=#{inspect init_arg}")

    # initialize state
    state = struct(%__MODULE__{}, init_arg)
    with {:ok, socket} <- udp_open(state.listen_port),
      {:ok, listen_port} <- :inet.port(socket)
    do
      state = %{state|
        udp_clients: MapSet.new(),
        listen_socket: socket,
        listen_port: listen_port,
      }
      {:ok, state, {:continue, {:startup_tasks, []}}}
    end
  end

  # API

  # Callbacks

  def handle_continue({:startup_tasks, []}, state) do
    Logger.info("#{__MODULE__}: status=running user_id=#{state.user_id} listen_port=#{state.listen_port}")

    {:noreply, state, state.hibernate_timeout}
  end

  # called when a handoff has been initiated due to changes
  # in cluster topology, valid response values are:
  #
  #   - `:restart`, to simply restart the process on the new node
  #   - `{:resume, state}`, to hand off some state to the new process
  #   - `:ignore`, to leave the process running on its current node
  #
  def handle_call({:swarm, :begin_handoff}, _from, state) do
    {:reply, {:resume, state}, state, state.hibernate_timeout}
  end
  def handle_call({:fetch_udp_clients, []}, _from, state) do
    udp_clients = MapSet.to_list(state.udp_clients) |> Enum.sort()
    {:reply, {:ok, udp_clients}, state, state.hibernate_timeout}
  end
  def handle_call({:fetch_udp_listen_port, []}, _from, state) do
    {:reply, {:ok, state.listen_port}, state, state.hibernate_timeout}
  end

  # called after the process has been restarted on its new node,
  # and the old process' state is being handed off. This is only
  # sent if the return to `begin_handoff` was `{:resume, state}`.
  # **NOTE**: This is called *after* the process is successfully started,
  # so make sure to design your processes around this caveat if you
  # wish to hand off state like this.
  def handle_cast({:swarm, :end_handoff, _handoff_state}, state) do
    # update state from DB if applicable
    {:noreply, state, state, state.hibernate_timeout}
  end
  # called when a network split is healed and the local process
  # should continue running, but a duplicate process on the other
  # side of the split is handing off its state to us. You can choose
  # to ignore the handoff state, or apply your own conflict resolution
  # strategy
  def handle_cast({:swarm, :resolve_conflict, _handoff_state}, state) do
    # update state from DB if applicable
    {:noreply, state, state, state.hibernate_timeout}
  end

  def handle_info({:udp, socket, address, port, data}, state) do
    # note the client
    udp_client = "#{:inet.ntoa(address)}:#{port}"
    state = %{state|udp_clients: MapSet.put(state.udp_clients, udp_client)}

    # parse the packet
    state =
      case RacingTelemetry.F122.Packets.from_binary(data) do
        # motion
        {:ok, %F122PacketMotionData{} = motion_data} ->
          run_broadcast("player_car_motion_gForce", motion_data, state)
          state

        # lap_Data
        {:ok, %F122PacketLapData{} = lap_data} ->
          %{state|f1_22_packets_lap_data: [lap_data|state.f1_22_packets_lap_data]}

        # car_telemetry
        {:ok, %F122PacketCarTelemetry{} = car_telemetry} ->
          %{state|f1_22_packets_car_telemetry: [car_telemetry|state.f1_22_packets_car_telemetry]}

        # event
        {:ok, %F122PacketEventData{} = _event} ->
          state

        # session
        {:ok, %F122PacketSession{} = session} ->
          %{state|f1_22_packets_session: [session|state.f1_22_packets_session]}

        # generic packet: not parsing this packet type yet
        {:ok, %F122Packet{} = packet} ->
          # Logger.info("f1_22_packet=#{inspect packet, pretty: true}")
          maybe_sample_packet(packet, data, state)

        error ->
          Logger.error("f1_22_packet=#{inspect error}")
          state
      end

    # store lap_data packets
    state =
      case length(state.f1_22_packets_lap_data) >= 10 do
        true -> store_f1_22_lap_data_packets(state)
        false -> state
      end

    # store car_telemetry packets
    state =
      case length(state.f1_22_packets_car_telemetry) >= 10 do
        true -> store_f1_22_lap_telemetry_packets(state)
        false -> state
      end

    # store session packets
    state =
      case length(state.f1_22_packets_session) >= 10 do
        true -> store_f1_22_session_packets(state)
        false -> state
      end

    # done
    {:noreply, state, state.hibernate_timeout}
  end
  # this message is sent when this process should die
  # because it is being moved, use this as an opportunity
  # to clean up
  def handle_info({:swarm, :die}, state) do
    {:stop, :shutdown, state}
  end
  def handle_info(:timeout, state) do
    {:noreply, state, :hibernate}
  end

  def terminate(reason, state) do
    Logger.debug("terminate: reason=#{inspect reason} state=#{inspect state}")

    # close the socket if applicable
    state =
      case is_nil(state.listen_socket) do
        # nothing to do
        true ->
          state

        # close the socket
        false ->
          :gen_udp.close(state.listen_socket)
          %{state|listen_socket: nil}
      end

    # done
    {reason, state}
  end

  # Logic/Helpers

  @doc false
  def store_f1_22_session_packets(state) do
    items = state.f1_22_packets_session
    Task.Supervisor.start_child(RacingTelemetry.TaskSupervisor, fn ->
      Enum.each(items, fn item ->
        case F122SessionPackets.create_f1_22_session_packet(item) do
          {:ok, _} -> :ok
          {:error, reason} -> log_store_packet_error("store_f1_22_session_packets", reason)
        end
      end)
    end)
    %{state|f1_22_packets_session: []}
  end

  @doc false
  def store_f1_22_lap_data_packets(state) do
    items = state.f1_22_packets_lap_data
    Task.Supervisor.start_child(RacingTelemetry.TaskSupervisor, fn ->
      Enum.each(items, fn item ->
        case F122LapDataPackets.create_f1_22_lap_data_packet(item) do
          {:ok, _} -> :ok
          {:error, reason} -> log_store_packet_error("store_f1_22_lap_data_packets", reason)
        end
      end)
    end)
    %{state|f1_22_packets_lap_data: []}
  end

  @doc false
  def store_f1_22_lap_telemetry_packets(state) do
    items = state.f1_22_packets_car_telemetry
    Task.Supervisor.start_child(RacingTelemetry.TaskSupervisor, fn ->
      Enum.each(items, fn item ->
        case F122CarTelemetryPackets.create_f1_22_car_telemetry_packet(item) do
          {:ok, _} -> :ok
          {:error, reason} -> log_store_packet_error("store_f1_22_lap_telemetry_packets", reason)
        end
      end)
    end)
    %{state|f1_22_packets_car_telemetry: []}
  end

  @doc false
  def log_store_packet_error(key, %Ecto.Changeset{} = reason) do
    errors = RT.Changeset.format_changeset_errors(reason)
    Logger.error("#{key}: reason=#{inspect errors}")
  end
  def log_store_packet_error(key, reason) do
    Logger.error("#{key}: reason=#{inspect reason}")
  end

  @doc false
  def run_broadcast("player_car_motion_gForce", %F122PacketMotionData{} = motion_data, state) do
    %F122PacketMotionData{
      m_header: %F122PacketHeader{m_playerCarIndex: m_playerCarIndex},
      m_carMotionData: m_carMotionData,
    } = motion_data
    %F122PacketMotionCarMotion{
      m_gForceLateral: m_gForceLateral,
      m_gForceLongitudinal: m_gForceLongitudinal,
      m_gForceVertical: m_gForceVertical,
    } = Enum.at(m_carMotionData, m_playerCarIndex)

    # forward/aft
    {m_gForceLongitudinalForward, m_gForceLongitudinalAft} =
      case m_gForceLongitudinal < 0 do
        true -> {(m_gForceLongitudinal * -1), 0.0}
        false -> {0.0, m_gForceLongitudinal}
      end

    # left/right
    {m_gForceLateralLeft, m_gForceLateralRight} =
      case m_gForceLateral < 0 do
        true -> {(m_gForceLateral * -1), 0.0}
        false -> {0.0, m_gForceLateral}
      end

    # broadcast
    topic = "f1_22:/users/#{state.user_id}/player_car_motion_gForce"
    payload = %{
      topic: topic,
      key: {"f1_22", "users", state.user_id, "player_car_motion_gForce"},
      meta: %{
        user_id: state.user_id,
      },
      data: %{
        m_gForceLongitudinal: m_gForceLongitudinal,
        m_gForceLongitudinalForward: m_gForceLongitudinalForward,
        m_gForceLongitudinalAft: m_gForceLongitudinalAft,
        m_gForceLateral: m_gForceLateral,
        m_gForceLateralLeft: m_gForceLateralLeft,
        m_gForceLateralRight: m_gForceLateralRight,
        m_gForceVertical: m_gForceVertical,
      }
    }
    Phoenix.PubSub.broadcast(RacingTelemetry.PubSub, topic, payload)
  end
  def run_broadcast("udp_clients", state) do
    # get client list
    udp_clients = MapSet.to_list(state.udp_clients) |> Enum.sort()

    # broadcast
    topic = "f1_22:/users/#{state.user_id}/udp_clients"
    payload = %{
      topic: topic,
      key: {"f1_22", "users", state.user_id, "udp_clients"},
      meta: %{
        user_id: state.user_id,
      },
      data: %{
       udp_clients: udp_clients,
      }
    }
    Phoenix.PubSub.broadcast(RacingTelemetry.PubSub, topic, payload)
  end

  @doc false
  def maybe_sample_packet(%{m_header: %{packet_type: packet_type}} = packet, data, state) do
    case Enum.member?(state.packet_type_samples, packet_type) do
      true -> state
      false -> sample_packet(packet, data, state)
    end
  end
  def maybe_sample_packet(_packet, _data, state) do
    # not sure what type of packet this is
    state
  end

  @doc false
  def sample_packet(%{m_header: %{packet_type: packet_type}}, data, state) do
    File.write!("/tmp/racing-telemetry-packet-sample.#{packet_type}.dat", data)
    packet_type_samples = [packet_type|state.packet_type_samples]
    %{state|packet_type_samples: packet_type_samples}
  end

  # open the UDP port to listen for telemetry packets
  defp udp_open(listen_port) do
    case :gen_udp.open(listen_port, [:binary, active: true]) do
      {:ok, socket} -> {:ok, socket}
      {:error, :eaddrinuse} -> {:error, %{listen_port: ["port '#{listen_port}' is already in use"]}}
      {:error, reason} -> {:error, reason}
    end
  end

end

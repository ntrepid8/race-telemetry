defmodule RacingTelemetry.F122Server do
  @doc """
  Receive UDP packets from an "F1 22" game.

  """
  use GenServer, restart: :temporary
  require Logger
  alias RacingTelemetry.F122.Packets.{
    F122PacketHeader,
    F122PacketMotionData,
    F122PacketMotionCarMotion,
  }

  defstruct [
    # config
    listen_port: 24134,  # "F1" is the hex number 241 and "22" is the hex number 34

    # runtime
    listen_socket: nil,
    packet_type_samples: [],

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
    with {:ok, socket} <- :gen_udp.open(state.listen_port, [:binary, active: true]) do
      state = %{state|listen_socket: socket}
      {:ok, state, {:continue, {:startup_tasks, []}}}
    end
  end

  # API

  # Callbacks

  def handle_continue({:startup_tasks, []}, state) do

    {:noreply, state, state.hibernate_timeout}
  end

  def handle_info({:udp, socket, address, port, data}, state) do
    # parse the packet
    state =
      case RacingTelemetry.F122.Packets.from_binary(data) do
        {:ok, %F122PacketMotionData{} = motion_data} ->
          run_broadcast("player_car_motion_gForce", motion_data)
          state

        {:ok, packet} ->
          # Logger.info("f1_22_packet=#{inspect packet, pretty: true}")
          maybe_sample_packet(packet, data, state)
        error ->
          Logger.error("f1_22_packet=#{inspect error}")
          state
      end

    # done
    {:noreply, state}
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
  def run_broadcast("player_car_motion_gForce", %F122PacketMotionData{} = motion_data) do
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
    Phoenix.PubSub.broadcast(
      RacingTelemetry.PubSub,
      "player_car_motion_gForce",
      %{
        topic: "player_car_motion_gForce",
        data: %{
          m_gForceLongitudinal: m_gForceLongitudinal,
          m_gForceLongitudinalForward: m_gForceLongitudinalForward,
          m_gForceLongitudinalAft: m_gForceLongitudinalAft,
          m_gForceLateral: m_gForceLateral,
          m_gForceLateralLeft: m_gForceLateralLeft,
          m_gForceLateralRight: m_gForceLateralRight,
          m_gForceVertical: m_gForceVertical,
        }
      })
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

end

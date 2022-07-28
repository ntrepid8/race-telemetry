defmodule RacingTelemetry.F122Server do
  @doc """
  Receive UDP packets from an "F1 22" game.

  """
  use GenServer, restart: :temporary
  require Logger

  defstruct [
    # config
    listen_port: 24134,  # "F1" is the hex number 241 and "22" is the hex number 34

    # runtime
    listen_socket: nil,

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
    Logger.info(
      "receive_data: " <>
      "socket=#{inspect socket} " <>
      "address=#{inspect address} " <>
      "port=#{inspect port} " <>
      "data_byte_size=#{byte_size(data)}")

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

end

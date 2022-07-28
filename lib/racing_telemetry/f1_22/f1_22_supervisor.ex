defmodule RacingTelemetry.F122Supervisor do
  @moduledoc """
  Start servers to listen for UDP packets from "F1 22" games.

  """
  use DynamicSupervisor

  def start_link(init_arg \\ []) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: []
    )
  end

  @doc """
  Registers a new worker, and creates the worker process
  """
  def register(%{listen_port: listen_port} = init_arg, opts \\ []) when is_integer(listen_port) do
    # spec = {RacingTelemetry.F122Server, [init_arg, opts]}
    spec = %{
      id: {:f1_22_server, listen_port},
      start: {RacingTelemetry.F122Server, :start_link, [init_arg, opts]}
    }
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

end

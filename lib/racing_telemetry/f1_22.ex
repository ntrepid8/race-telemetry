defmodule RacingTelemetry.F122 do
  @moduledoc """
  F1 22 Context.

  """
  require Logger

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

end

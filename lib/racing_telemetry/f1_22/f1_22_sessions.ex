defmodule RacingTelemetry.F122Sessions do
  @moduledoc """
  The F122Sessions context.

  Functions to pull data about F1 22 sessions.

  """
  use RacingTelemetry.Query
  require Logger
  alias RacingTelemetry, as: RT


  @doc """
  Find a list of available F1 22 sessions.

  """
  def find_f1_22_sessions() do
    RT.F122.Models.F122SessionPackets.fetch_unique_f1_22_session_packets_by_m_sessionUID()
    |> case do
      {:ok, items} -> items
      {:error, reason} -> raise "find_f1_22_sessions: reason=#{inspect reason}"
    end
  end

end

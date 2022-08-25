defmodule RacingTelemetry.F122.Packets do
  @moduledoc """
  Parse UDP packets from F1 22

  """
  require Logger
  alias RacingTelemetry.F122.Packets.{
    F122Packet,
    F122PacketHeader,
    F122PacketEventData,
    F122PacketMotionData,
    F122PacketLapData,
    F122PacketCarTelemetry,
    F122PacketSession,
    F122PacketSessionHistory,
  }


  @doc """
  Parse a Data packet from F1 22.

  """
  def from_binary(data) when is_binary(data), do: from_binary(data, [])
  def from_binary(data, opts) when is_binary(data) and is_list(opts) do
    with {:ok, {%F122PacketHeader{} = ph0, rest}} <- F122PacketHeader.from_binary(data),
      do: from_binary(ph0, rest, opts)
  end

  @doc false
  def from_binary(%F122PacketHeader{} = ph0, data), do: from_binary(ph0, data, [])
  def from_binary(%F122PacketHeader{packet_type: "event"} = ph0, data, _opts) do
    F122PacketEventData.from_binary(ph0, data)
  end
  def from_binary(%F122PacketHeader{packet_type: "motion"} = ph0, data, _opts) do
    F122PacketMotionData.from_binary(ph0, data)
  end
  def from_binary(%F122PacketHeader{packet_type: "lap_data"} = ph0, data, _opts) do
    F122PacketLapData.from_binary(ph0, data)
  end
  def from_binary(%F122PacketHeader{packet_type: "car_telemetry"} = ph0, data, _opts) do
    F122PacketCarTelemetry.from_binary(ph0, data)
  end
  def from_binary(%F122PacketHeader{packet_type: "session"} = ph0, data, _opts) do
    F122PacketSession.from_binary(ph0, data)
  end
  def from_binary(%F122PacketHeader{packet_type: "session_history"} = ph0, data, opts) do
    F122PacketSessionHistory.from_binary(ph0, data, opts)
  end
  def from_binary(%F122PacketHeader{} = ph0, _data, _opts) do
    {:ok, %F122Packet{m_header: ph0}}
  end

end

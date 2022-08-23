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
  }


  @doc """
  Parse a Data packet from F1 22.

  """
  def from_binary(data) do
    with {:ok, {%F122PacketHeader{} = ph0, rest}} <- F122PacketHeader.from_binary(data),
      do: from_binary(ph0, rest)
  end

  @doc false
  def from_binary(%F122PacketHeader{packet_type: "event"} = ph0, data) do
    F122PacketEventData.from_binary(ph0, data)
  end
  def from_binary(%F122PacketHeader{packet_type: "motion"} = ph0, data) do
    F122PacketMotionData.from_binary(ph0, data)
  end
  def from_binary(%F122PacketHeader{packet_type: "lap_data"} = ph0, data) do
    F122PacketLapData.from_binary(ph0, data)
  end
  def from_binary(%F122PacketHeader{packet_type: "car_telemetry"} = ph0, data) do
    F122PacketCarTelemetry.from_binary(ph0, data)
  end
  def from_binary(%F122PacketHeader{packet_type: "session"} = ph0, data) do
    F122PacketSession.from_binary(ph0, data)
  end
  def from_binary(%F122PacketHeader{} = ph0, _data) do
    {:ok, %F122Packet{m_header: ph0}}
  end

end

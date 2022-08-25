defmodule RacingTelemetry.F122.Packets.F122PacketSessionHistoryLap do
  @moduledoc """
  F122PacketSessionHistoryLap

  Size: 88 bits / 11 bytes

  """
  use Bitwise, skip_operators: true
  require Logger
  alias RacingTelemetry.F122.Packets.{
    F122PacketHeader,
  }

  defstruct [
    # original
    m_lapTimeInMS: nil,       # uint32 - Lap time in milliseconds
    m_sector1TimeInMS: nil,   # uint16 - Sector 1 time in milliseconds
    m_sector2TimeInMS: nil,   # uint16 - Sector 2 time in milliseconds
    m_sector3TimeInMS: nil,   # uint16 - Sector 3 time in milliseconds
    m_lapValidBitFlags: nil,  # uint8 - 0x01 bit set-lap valid
                              #         0x02 bit set-sector 1 valid
                              #         0x04 bit set-sector 2 valid
                              #         0x08 bit set-sector 3 valid

    # computed
    lap_valid: nil,
    sector1_valid: nil,
    sector2_valid: nil,
    sector3_valid: nil,

    # header fields (for indexing)
    m_sessionUID: nil,
    m_sessionTime: nil,
    m_frameIdentifier: nil,
  ]

  def from_binary(%F122PacketHeader{packet_type: "session_history"} = ph0, <<
    m_lapTimeInMS::unsigned-little-integer-size(32),
    m_sector1TimeInMS::unsigned-little-integer-size(16),
    m_sector2TimeInMS::unsigned-little-integer-size(16),
    m_sector3TimeInMS::unsigned-little-integer-size(16),
    m_lapValidBitFlags::unsigned-little-integer-size(8),
  >>) do
    {:ok, %__MODULE__{
      # original
      m_lapTimeInMS: m_lapTimeInMS,
      m_sector1TimeInMS: m_sector1TimeInMS,
      m_sector2TimeInMS: m_sector2TimeInMS,
      m_sector3TimeInMS: m_sector3TimeInMS,
      m_lapValidBitFlags: m_lapValidBitFlags,

      # computed
      lap_valid: get_lap_valid(m_lapValidBitFlags),
      sector1_valid: get_sector1_valid(m_lapValidBitFlags),
      sector2_valid: get_sector2_valid(m_lapValidBitFlags),
      sector3_valid: get_sector3_valid(m_lapValidBitFlags),

      # header field (for indexing)
      m_sessionUID: ph0.m_sessionUID,
      m_sessionTime: ph0.m_sessionTime,
      m_frameIdentifier: ph0.m_frameIdentifier,
    }}
  end
  def from_binary(ph0, data) do
    Logger.error(
      "m_sessionUID=#{ph0.m_sessionUID} " <>
      "m_frameIdentifier=#{ph0.m_frameIdentifier} " <>
      "data_byte_size=#{byte_size(data)} ")
    {:error, %{packet_session_history_lap: ["is invalid"]}}
  end

  def get_lap_valid(m_lapValidBitFlags), do: band(m_lapValidBitFlags, 1) > 0

  def get_sector1_valid(m_lapValidBitFlags), do: band(m_lapValidBitFlags, 2)  > 0

  def get_sector2_valid(m_lapValidBitFlags), do: band(m_lapValidBitFlags, 4)  > 0

  def get_sector3_valid(m_lapValidBitFlags), do: band(m_lapValidBitFlags, 8)  > 0

end

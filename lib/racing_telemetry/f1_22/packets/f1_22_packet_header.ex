defmodule RacingTelemetry.F122.Packets.F122PacketHeader do
  @moduledoc """
  Standard packet header for F1 22

  Size: 192 bits or 24 bytes

  """

  defstruct [
    # original
    m_packetFormat: nil,             # uint16  - 2022
    m_gameMajorVersion: nil,         # uint8   - Game major version -"X.00"
    m_gameMinorVersion: nil,         # uint8   - Game minor version -"1.XX"
    m_packetVersion: nil,            # uint8   - Version of this packet type, all start from 1
    m_packetId: nil,                 # uint8   - Identifier for the packet type, see below
    m_sessionUID: nil,               # uint64  - Unique identifier for the session
    m_sessionTime: nil,              # float32 - Session timestamp
    m_frameIdentifier: nil,          # uint32  - Identifier for the frame the data was retrieved on
    m_playerCarIndex: nil,           # uint8   - Index of player's car in the array
    m_secondaryPlayerCarIndex: nil,  # uint8   - Index of 2nd player's car in the array, 255 if no 2nd player

    # computed
    packet_type: nil,
  ]

  @packet_types %{
    0 => "motion",
    1 => "session",
    2 => "lap_data",
    3 => "event",
    4 => "participants",
    5 => "car_setups",
    6 => "car_telemetry",
    7 => "car_status",
    8 => "final_classification",
    9 => "lobby_info",
    10 => "car_damage",
    11 => "session_history",
  }

  def from_binary(<<
    m_packetFormat::unsigned-little-integer-size(16),
    m_gameMajorVersion::unsigned-little-integer-size(8),
    m_gameMinorVersion::unsigned-little-integer-size(8),
    m_packetVersion::unsigned-little-integer-size(8),
    m_packetId::unsigned-little-integer-size(8),
    m_sessionUID::unsigned-little-integer-size(64),
    m_sessionTime::little-float-size(32),
    m_frameIdentifier::unsigned-little-integer-size(32),
    m_playerCarIndex::unsigned-little-integer-size(8),
    m_secondaryPlayerCarIndex::unsigned-little-integer-size(8),
    rest::binary
  >>) do
    {:ok, {%__MODULE__{
      # original data
      m_packetFormat: m_packetFormat,
      m_gameMajorVersion: m_gameMajorVersion,
      m_gameMinorVersion: m_gameMinorVersion,
      m_packetVersion: m_packetVersion,
      m_packetId: m_packetId,
      m_sessionUID: m_sessionUID,
      m_sessionTime: m_sessionTime,
      m_frameIdentifier: m_frameIdentifier,
      m_playerCarIndex: m_playerCarIndex,
      m_secondaryPlayerCarIndex: m_secondaryPlayerCarIndex,

      # computed values
      packet_type: Map.get(@packet_types, m_packetId, "invalid"),
    }, rest}}
  end
  def from_binary(_data) do
    {:error, %{packet_header: ["is invalid"]}}
  end

end

defmodule RacingTelemetry.F122.Packets.F122PacketSessionMarshalZone do
  @moduledoc """
  F122PacketSessionMarshalZone

  Size: 40 bits / 5 bytes

  """

  defstruct [
    m_zoneStart: nil,  # float32 - Fraction (0..1) of way through the lap the marshal zone starts
    m_zoneFlag: nil,   # int8 - -1 = invalid/unknown, 0 = none, 1 = green, 2 = blue, 3 = yellow, 4 = red
  ]

  def from_binary(<<
    m_zoneStart::little-float-size(32),
    m_zoneFlag::little-integer-size(8)
  >>) do
    {:ok, %__MODULE__{m_zoneStart: m_zoneStart, m_zoneFlag: m_zoneFlag}}
  end

end

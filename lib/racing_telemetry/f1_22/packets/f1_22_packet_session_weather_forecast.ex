defmodule RacingTelemetry.F122.Packets.F122PacketSessionWeatherForecast do
  @moduledoc """
  F122PacketSessionWeatherForecast

  Size: 64 bits / 8 Bytes

  """

  defstruct [
    m_sessionType: nil,             # uint8 - 0 = unknown, 1 = P1, 2 = P2, 3 = P3, 4 = Short P, 5 = Q1
                                    #         6 = Q2, 7 = Q3, 8 = Short Q, 9 = OSQ, 10 = R, 11 = R2
                                    #         12 = R3, 13 = Time Trial
    m_timeOffset: nil,              # uint8 - Time in minutes the forecast is for
    m_weather: nil,                 # uint8 - Weather - 0 = clear, 1 = light cloud, 2 = overcast
    m_trackTemperature: nil,        # int8 - Track temp. in degrees Celsius
    m_trackTemperatureChange: nil,  # int8 - Track temp. change – 0 = up, 1 = down, 2 = no change
    m_airTemperature: nil,          # int8 - Air temp. in degrees celsius
    m_airTemperatureChange: nil,    # int8 - Air temp. change – 0 = up, 1 = down, 2 = no change
    m_rainPercentage: nil,          # uint8 - Rain percentage (0-100)
  ]

  def from_binary(<<
    m_sessionType::unsigned-little-integer-size(8),
    m_timeOffset::unsigned-little-integer-size(8),
    m_weather::unsigned-little-integer-size(8),
    m_trackTemperature::little-integer-size(8),
    m_trackTemperatureChange::little-integer-size(8),
    m_airTemperature::little-integer-size(8),
    m_airTemperatureChange::little-integer-size(8),
    m_rainPercentage::unsigned-little-integer-size(8),
  >>) do
    {:ok, %__MODULE__{
      m_sessionType: m_sessionType,
      m_timeOffset: m_timeOffset,
      m_weather: m_weather,
      m_trackTemperature: m_trackTemperature,
      m_trackTemperatureChange: m_trackTemperatureChange,
      m_airTemperature: m_airTemperature,
      m_airTemperatureChange: m_airTemperatureChange,
      m_rainPercentage: m_rainPercentage,
    }}
  end

end

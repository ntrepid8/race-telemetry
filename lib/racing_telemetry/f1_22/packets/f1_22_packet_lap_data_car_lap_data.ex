defmodule RacingTelemetry.F122.Packets.F122PacketLapDataCarLapData do
  @moduledoc """
  LapData information about individual cars on the track.

  Part of the F122PacketLapData structure.

  Size: 344 bits / 43 bytes

  """
  require Logger
  alias RacingTelemetry.F122.Packets.{
    F122PacketHeader,
  }

  defstruct [
    m_lastLapTimeInMS: nil,              # uint32 - Last lap time in milliseconds
    m_currentLapTimeInMS: nil,           # uint32 - Current time around the lap in milliseconds
    m_sector1TimeInMS: nil,              # uint16 - Sector 1 time in milliseconds
    m_sector2TimeInMS: nil,              # uint16 - Sector 2 time in milliseconds
    m_lapDistance: nil,                  # float32 - Distance vehicle is around current lap in metres – could
                                         #           be negative if line hasn’t been crossed yet
    m_totalDistance: nil,                # float32 - Total distance travelled in session in metres – could
                                         #           be negative if line hasn’t been crossed yet
    m_safetyCarDelta: nil,               # float32 - Delta in seconds for safety car
    m_carPosition: nil,                  # uint8 - Car race position
    m_currentLapNum: nil,                # uint8 - Current lap number
    m_pitStatus: nil,                    # uint8 - 0 = none, 1 = pitting, 2 = in pit area
    m_numPitStops: nil,                  # uint8 - Number of pit stops taken in this race
    m_sector: nil,                       # uint8 - 0 = sector1, 1 = sector2, 2 = sector3
    m_currentLapInvalid: nil,            # uint8 - Current lap invalid - 0 = valid, 1 = invalid
    m_penalties: nil,                    # uint8 - Accumulated time penalties in seconds to be added
    m_warnings: nil,                     # uint8 - Accumulated number of warnings issued
    m_numUnservedDriveThroughPens: nil,  # uint8 - Num drive through pens left to serve
    m_numUnservedStopGoPens: nil,        # uint8 - Num stop go pens left to serve
    m_gridPosition: nil,                 # uint8 - Grid position the vehicle started the race in
    m_driverStatus: nil,                 # uint8 - Status of driver - 0 = in garage, 1 = flying lap
                                         #         2 = in lap, 3 = out lap, 4 = on track
    m_resultStatus: nil,                 # uint8 - Result status - 0 = invalid, 1 = inactive, 2 = active
    m_pitLaneTimerActive: nil,           # uint8 - Pit lane timing, 0 = inactive, 1 = active
    m_pitLaneTimeInLaneInMS: nil,        # uint16 - If active, the current time spent in the pit lane in ms
    m_pitStopTimerInMS: nil,             # uint16 - Time of the actual pit stop in ms
    m_pitStopShouldServePen: nil,        # uint8 - Whether the car should serve a penalty at this stop

    # extra
    car_index: nil,
    pit_status: nil,
    sector: nil,
    current_lap_invalid: nil,
    driver_status: nil,
    result_status: nil,
    pit_lane_timer_active: nil,

    # header fields (for indexing)
    m_sessionUID: nil,
    m_sessionTime: nil,
    m_frameIdentifier: nil,
  ]

  def from_binary(%F122PacketHeader{packet_type: "lap_data"} = ph0, car_index, <<
    m_lastLapTimeInMS::unsigned-little-integer-size(32),
    m_currentLapTimeInMS::unsigned-little-integer-size(32),
    m_sector1TimeInMS::unsigned-little-integer-size(16),
    m_sector2TimeInMS::unsigned-little-integer-size(16),
    m_lapDistance::little-float-size(32),
    m_totalDistance::little-float-size(32),
    m_safetyCarDelta::little-float-size(32),
    m_carPosition::unsigned-little-integer-size(8),
    m_currentLapNum::unsigned-little-integer-size(8),
    m_pitStatus::unsigned-little-integer-size(8),
    m_numPitStops::unsigned-little-integer-size(8),
    m_sector::unsigned-little-integer-size(8),
    m_currentLapInvalid::unsigned-little-integer-size(8),
    m_penalties::unsigned-little-integer-size(8),
    m_warnings::unsigned-little-integer-size(8),
    m_numUnservedDriveThroughPens::unsigned-little-integer-size(8),
    m_numUnservedStopGoPens::unsigned-little-integer-size(8),
    m_gridPosition::unsigned-little-integer-size(8),
    m_driverStatus::unsigned-little-integer-size(8),
    m_resultStatus::unsigned-little-integer-size(8),
    m_pitLaneTimerActive::unsigned-little-integer-size(8),
    m_pitLaneTimeInLaneInMS::unsigned-little-integer-size(16),
    m_pitStopTimerInMS::unsigned-little-integer-size(16),
    m_pitStopShouldServePen::unsigned-little-integer-size(8)
  >>) do
    {:ok, %__MODULE__{
      # original
      m_lastLapTimeInMS: m_lastLapTimeInMS,
      m_currentLapTimeInMS: m_currentLapTimeInMS,
      m_sector1TimeInMS: m_sector1TimeInMS,
      m_sector2TimeInMS: m_sector2TimeInMS,
      m_lapDistance: m_lapDistance,
      m_totalDistance: m_totalDistance,
      m_safetyCarDelta: m_safetyCarDelta,
      m_carPosition: m_carPosition,
      m_currentLapNum: m_currentLapNum,
      m_pitStatus: m_pitStatus,
      m_numPitStops: m_numPitStops,
      m_sector: m_sector,
      m_currentLapInvalid: m_currentLapInvalid,
      m_penalties: m_penalties,
      m_warnings: m_warnings,
      m_numUnservedDriveThroughPens: m_numUnservedDriveThroughPens,
      m_numUnservedStopGoPens: m_numUnservedStopGoPens,
      m_gridPosition: m_gridPosition,
      m_driverStatus: m_driverStatus,
      m_resultStatus: m_resultStatus,
      m_pitLaneTimerActive: m_pitLaneTimerActive,
      m_pitLaneTimeInLaneInMS: m_pitLaneTimeInLaneInMS,
      m_pitStopTimerInMS: m_pitStopTimerInMS,
      m_pitStopShouldServePen: m_pitStopShouldServePen,

      # computed
      car_index: car_index,
      pit_status: get_pit_status(m_pitStatus),
      sector: get_sector(m_sector),
      current_lap_invalid: get_current_lap_invalid(m_currentLapInvalid),
      driver_status: get_driver_status(m_driverStatus),
      result_status: get_result_status(m_resultStatus),
      pit_lane_timer_active: get_pit_lane_timer_active(m_pitLaneTimerActive),

      # header field (for indexing)
      m_sessionUID: ph0.m_sessionUID,
      m_sessionTime: ph0.m_sessionTime,
      m_frameIdentifier: ph0.m_frameIdentifier,
    }}
  end
  def from_binary(car_index, data) do
    Logger.error("car_index=#{car_index} data_byte_size=#{byte_size(data)} data=#{inspect data}")
    {:error, %{packet_lap_data_car_lap_data: ["is invalid"]}}
  end

  defp get_pit_status(0), do: "none"
  defp get_pit_status(1), do: "pitting"
  defp get_pit_status(2), do: "in pit area"
  defp get_pit_status(_m_pitStatus), do: nil

  defp get_sector(m_sector) when is_integer(m_sector), do: m_sector + 1
  defp get_sector(_m_sector), do: nil

  defp get_current_lap_invalid(0), do: "valid"
  defp get_current_lap_invalid(1), do: "invalid"
  defp get_current_lap_invalid(_m_currentLapInvalid), do: nil

  defp get_driver_status(0), do: "in garage"
  defp get_driver_status(1), do: "flying lap"
  defp get_driver_status(2), do: "in lap"
  defp get_driver_status(3), do: "out lap"
  defp get_driver_status(4), do: "on track"
  defp get_driver_status(_m_driverStatus), do: nil

  defp get_result_status(0), do: "invalid"
  defp get_result_status(1), do: "inactive"
  defp get_result_status(2), do: "active"
  defp get_result_status(_m_resultStatus), do: nil

  defp get_pit_lane_timer_active(0), do: "inactive"
  defp get_pit_lane_timer_active(1), do: "active"
  defp get_pit_lane_timer_active(_m_pitLaneTimerActive), do: nil

end

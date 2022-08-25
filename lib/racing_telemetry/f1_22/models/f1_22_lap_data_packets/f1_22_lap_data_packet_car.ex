defmodule RacingTelemetry.F122.Models.F122LapDataPackets.F122LapDataPacketCar do
  use RacingTelemetry.Schema
  require Logger

  # fields that must always be present
  @required_fields [
    # original fields
    :m_lastLapTimeInMS,
    :m_currentLapTimeInMS,
    :m_sector1TimeInMS,
    :m_sector2TimeInMS,
    :m_lapDistance,
    :m_totalDistance,
    :m_safetyCarDelta,
    :m_carPosition,
    :m_currentLapNum,
    :m_pitStatus,
    :m_numPitStops,
    :m_sector,
    :m_currentLapInvalid,
    :m_penalties,
    :m_warnings,
    :m_numUnservedDriveThroughPens,
    :m_numUnservedStopGoPens,
    :m_gridPosition,
    :m_driverStatus,
    :m_resultStatus,
    :m_pitLaneTimerActive,
    :m_pitLaneTimeInLaneInMS,
    :m_pitStopTimerInMS,
    :m_pitStopShouldServePen,

    # extrafields
    :car_index,

     # header fields (for indexing)
    :m_sessionUID,
    :m_sessionTime,
    :m_frameIdentifier,
  ]

  # fields used by the system which are present on all record types
  @system_fields [
    :deleted,
    :live_mode,
  ]

  # fields that are permitted to change on "update" operations
  @permitted_fields [
    # extra fields
    :pit_status,
    :sector,
    :current_lap_invalid,
    :driver_status,
    :result_status,
    :pit_lane_timer_active,

    # associations
    :f1_22_lap_data_packet_id,
  ] ++ @system_fields ++ @required_fields

  @exclude_from_json_fields [
    :__meta__,
    :deleted,
    :iteration,
    :serial_number,
  ]

  @derive {Jason.Encoder, except: @exclude_from_json_fields}
  schema "f1_22_lap_data_packet_cars" do
    field :object, :string, virtual: true, default: "f1_22_lap_data_packet_car"

    # header fields (for indexing)
    field :m_sessionUID, :decimal       # uint64  - Unique identifier for the session
    field :m_sessionTime, :float        # float32 - Session timestamp (seconds since the session started)
    field :m_frameIdentifier, :integer  # uint32  - Identifier for the frame the data was retrieved on

    # original fields
    field :m_lastLapTimeInMS, :integer              # uint32 - Last lap time in milliseconds
    field :m_currentLapTimeInMS, :integer           # uint32 - Current time around the lap in milliseconds
    field :m_sector1TimeInMS, :integer              # uint16 - Sector 1 time in milliseconds
    field :m_sector2TimeInMS, :integer              # uint16 - Sector 2 time in milliseconds
    field :m_lapDistance, :float                    # float32 - Distance vehicle is around current lap in metres – could
                                                    #           be negative if line hasn’t been crossed yet
    field :m_totalDistance, :float                  # float32 - Total distance travelled in session in metres – could
                                                    #           be negative if line hasn’t been crossed yet
    field :m_safetyCarDelta, :float                 # float32 - Delta in seconds for safety car
    field :m_carPosition, :integer                  # uint8 - Car race position
    field :m_currentLapNum, :integer                # uint8 - Current lap number
    field :m_pitStatus, :integer                    # uint8 - 0 = none, 1 = pitting, 2 = in pit area
    field :m_numPitStops, :integer                  # uint8 - Number of pit stops taken in this race
    field :m_sector, :integer                       # uint8 - 0 = sector1, 1 = sector2, 2 = sector3
    field :m_currentLapInvalid, :integer            # uint8 - Current lap invalid - 0 = valid, 1 = invalid
    field :m_penalties, :integer                    # uint8 - Accumulated time penalties in seconds to be added
    field :m_warnings, :integer                     # uint8 - Accumulated number of warnings issued
    field :m_numUnservedDriveThroughPens, :integer  # uint8 - Num drive through pens left to serve
    field :m_numUnservedStopGoPens, :integer        # uint8 - Num stop go pens left to serve
    field :m_gridPosition, :integer                 # uint8 - Grid position the vehicle started the race in
    field :m_driverStatus, :integer                 # uint8 - Status of driver - 0 = in garage, 1 = flying lap
                                                    #         2 = in lap, 3 = out lap, 4 = on track
    field :m_resultStatus, :integer                 # uint8 - Result status - 0 = invalid, 1 = inactive, 2 = active
    field :m_pitLaneTimerActive, :integer           # uint8 - Pit lane timing, 0 = inactive, 1 = active
    field :m_pitLaneTimeInLaneInMS, :integer        # uint16 - If active, the current time spent in the pit lane in ms
    field :m_pitStopTimerInMS, :integer             # uint16 - Time of the actual pit stop in ms
    field :m_pitStopShouldServePen, :integer        # uint8 - Whether the car should serve a penalty at this stop

    # extra fields
    field :car_index, :integer
    field :pit_status, :string
    field :sector, :integer
    field :current_lap_invalid, :string
    field :driver_status, :string
    field :result_status, :string
    field :pit_lane_timer_active, :string

    # associations
    belongs_to :f1_22_lap_data_packet, RacingTelemetry.F122.Models.F122LapDataPackets.F122LapDataPacket
    has_one :m_header, through: [:f1_22_lap_data_packet, :m_header]

    # system fields (general meta-data)
    field :iteration, :integer, read_after_writes: true      # optimistic lock
    field :serial_number, :integer, read_after_writes: true  # deterministic ordering
    field :deleted, :boolean, default: false                 # logical delete
    field :live_mode, :boolean, default: true                # true == real/live data, false == test data (like stripe)
    timestamps()                                             # inserted_at, updated_at
  end

  @doc false
  def changeset(data, %{__struct__: _} = attrs), do: changeset(data, Map.from_struct(attrs))
  def changeset(data, attrs) do
    data
    |> cast(attrs, @permitted_fields)
    |> validate_required(@required_fields)
    |> optimistic_lock(:iteration)
  end

end

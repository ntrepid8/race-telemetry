defmodule RacingTelemetry.F122.Models.F122SessionPackets.F122SessionPacket do
  use RacingTelemetry.Schema
  require Logger

  # fields that must always be present
  @required_fields [
    # original fields
    :m_weather,
    :m_trackTemperature,
    :m_airTemperature,
    :m_totalLaps,
    :m_trackLength,
    :m_sessionType,
    :m_trackId,
    :m_formula,
    :m_sessionTimeLeft,
    :m_sessionDuration,
    :m_pitSpeedLimit,
    :m_gamePaused,
    :m_isSpectating,
    :m_spectatorCarIndex,
    :m_sliProNativeSupport,
    :m_numMarshalZones,
    :m_safetyCarStatus,
    :m_networkGame,
    :m_numWeatherForecastSamples,
    :m_forecastAccuracy,
    :m_aiDifficulty,
    :m_seasonLinkIdentifier,
    :m_weekendLinkIdentifier,
    :m_sessionLinkIdentifier,
    :m_pitStopWindowIdealLap,
    :m_pitStopWindowLatestLap,
    :m_pitStopRejoinPosition,
    :m_steeringAssist,
    :m_brakingAssist,
    :m_gearboxAssist,
    :m_pitAssist,
    :m_pitReleaseAssist,
    :m_ERSAssist,
    :m_DRSAssist,
    :m_dynamicRacingLine,
    :m_dynamicRacingLineType,
    :m_gameMode,
    :m_ruleSet,
    :m_timeOfDay,
    :m_sessionLength,

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
    :m_header_id,
    :session_type,
    :formula,
    :track,
    :safety_car_status,
    :network_game,
    :forecast_accuracy,
    :game_mode,
    :dynamic_racing_line,
    :ruleset,
    :session_length,
  ] ++ @system_fields ++ @required_fields

  @exclude_from_json_fields [
    :__meta__,
    :deleted,
    :iteration,
    :serial_number,
  ]

  @derive {Jason.Encoder, except: @exclude_from_json_fields}
  schema "f1_22_session_packets" do
    field :object, :string, virtual: true, default: "f1_22_session_packet"

    # header fields (for indexing)
    field :m_sessionUID, :decimal       # uint64  - Unique identifier for the session
    field :m_sessionTime, :float        # float32 - Session timestamp (seconds since the session started)
    field :m_frameIdentifier, :integer  # uint32  - Identifier for the frame the data was retrieved on

    # original fields
    field :m_weather, :integer                    # uint8 - Weather - 0 = clear, 1 = light cloud, 2 = overcast
    field :m_trackTemperature, :integer           # int8 - Track temp. in degrees celsius
    field :m_airTemperature, :integer             # int8 - Air temp. in degrees celsius
    field :m_totalLaps, :integer                  # uint8 - Total number of laps in this race
    field :m_trackLength, :integer                # uint16 - Track length in metres
    field :m_sessionType, :integer                # uint8 - 0 = unknown, 1 = P1, 2 = P2, 3 = P3, 4 = Short P
                                                  #         5 = Q1, 6 = Q2, 7 = Q3, 8 = Short Q, 9 = OSQ
                                                  #         10 = R, 11 = R2, 12 = R3, 13 = Time Trial
    field :m_trackId, :integer                    # int8 - -1 for unknown, see appendix
    field :m_formula, :integer                    # uint8 - Formula, 0 = F1 Modern, 1 = F1 Classic, 2 = F2,
                                                  #         3 = F1 Generic, 4 = Beta, 5 = Supercars
    field :m_sessionTimeLeft, :integer            # uint16 - Time left in session in seconds
    field :m_sessionDuration, :integer            # uint16 - Session duration in seconds
    field :m_pitSpeedLimit, :integer              # uint8 - Pit speed limit in kilometres per hour
    field :m_gamePaused, :integer                 # uint8 - Whether the game is paused – network game only
    field :m_isSpectating, :integer               # uint8 - Whether the player is spectating
    field :m_spectatorCarIndex, :integer          # uint8 - Index of the car being spectated
    field :m_sliProNativeSupport, :integer        # uint8 - SLI Pro support, 0 = inactive, 1 = active
    field :m_numMarshalZones, :integer            # uint8 - Number of marshal zones to follow
    field :m_safetyCarStatus, :integer            # uint8 - 0 = no safety car, 1 = full, 2 = virtual, 3 = formation lap
    field :m_networkGame, :integer                # uint8 - 0 = offline, 1 = online
    field :m_numWeatherForecastSamples, :integer  # uint8 - Number of weather samples to follow
    field :m_forecastAccuracy, :integer           # uint8 - 0 = Perfect, 1 = Approximate
    field :m_aiDifficulty, :integer               # uint8 - AI Difficulty rating – 0-110
    field :m_seasonLinkIdentifier, :integer       # uint32 - Identifier for season - persists across saves
    field :m_weekendLinkIdentifier, :integer      # uint32 - Identifier for weekend - persists across saves
    field :m_sessionLinkIdentifier, :integer      # uint32 - Identifier for session - persists across saves
    field :m_pitStopWindowIdealLap, :integer      # uint8 - Ideal lap to pit on for current strategy (player)
    field :m_pitStopWindowLatestLap, :integer     # uint8 - Latest lap to pit on for current strategy (player)
    field :m_pitStopRejoinPosition, :integer      # uint8 - Predicted position to rejoin at (player)
    field :m_steeringAssist, :integer             # uint8 - 0 = off, 1 = on
    field :m_brakingAssist, :integer              # uint8 - 0 = off, 1 = low, 2 = medium, 3 = high
    field :m_gearboxAssist, :integer              # uint8 - 1 = manual, 2 = manual & suggested gear, 3 = auto
    field :m_pitAssist, :integer                  # uint8 - 0 = off, 1 = on
    field :m_pitReleaseAssist, :integer           # uint8 - 0 = off, 1 = on
    field :m_ERSAssist, :integer                  # uint8 - 0 = off, 1 = on
    field :m_DRSAssist, :integer                  # uint8 - 0 = off, 1 = on
    field :m_dynamicRacingLine, :integer          # uint8 - 0 = off, 1 = corners only, 2 = full
    field :m_dynamicRacingLineType, :integer      # uint8 - 0 = 2D, 1 = 3D
    field :m_gameMode, :integer                   # uint8 - Game mode id - see appendix
    field :m_ruleSet, :integer                    # uint8 - Ruleset - see appendix
    field :m_timeOfDay, :integer                  # uint32 - Local time of day - minutes since midnight
    field :m_sessionLength, :integer              # uint8 - 0 = None, 2 = Very Short, 3 = Short, 4 = Medium
                                                  #         5 = Medium Long, 6 = Long, 7 = Full

    # extra fields
    field :session_type, :string
    field :formula, :string
    field :track, :string
    field :safety_car_status, :string
    field :network_game, :string
    field :forecast_accuracy, :string
    field :game_mode, :string
    field :dynamic_racing_line, :string
    field :ruleset, :string
    field :session_length, :string

    # associations
    belongs_to :m_header, RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader
    has_many :m_marshalZones, RacingTelemetry.F122.Models.F122SessionPackets.F122SessionPacketMarshalZone,
      foreign_key: :f1_22_session_packet_id
    has_many :m_weatherForecastSamples, RacingTelemetry.F122.Models.F122SessionPackets.F122SessionPacketWeatherForecast,
      foreign_key: :f1_22_session_packet_id

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
    |> cast_assoc(:m_header,
      with: &RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader.changeset/2)
    |> cast_assoc(:m_marshalZones,
      with: &RacingTelemetry.F122.Models.F122SessionPackets.F122SessionPacketMarshalZone.changeset/2)
    |> cast_assoc(:m_weatherForecastSamples,
      with: &RacingTelemetry.F122.Models.F122SessionPackets.F122SessionPacketWeatherForecast.changeset/2)
  end

end

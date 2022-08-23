defmodule RacingTelemetry.F122.Packets.F122PacketSession do
  @moduledoc """
  The session packet includes details about the current session in progress.

  Frequency: 2 per second
  Size: 632 bytes
  Version: 1

  """
  require Logger
  alias RacingTelemetry.F122.Packets.{
    F122PacketHeader,
    F122PacketSessionMarshalZone,
    F122PacketSessionWeatherForecast,
  }

  @session_type_ids %{
    0 => "unknown",
    1 => "P1",
    2 => "P2",
    3 => "P3",
    4 => "Short",
    5 => "Q1",
    6 => "Q2",
    7 => "Q3",
    8 => "Short Q",
    9 => "OSQ",
    10 => "R",
    11 => "R2",
    12 => "R3",
    13 => "Time Trial",
  }

  @formula_ids %{
    0 => "F1 Modern",
    1 => "F1 Classic",
    2 => "F2",
    3 => "F1 Generic",
    4 => "Beta",
    5 => "Supercars",
  }

  @game_mode_ids %{
    0 => "Event Mode",
    3 => "Grand Prix",
    5 => "Time Trial",
    6 => "Splitscreen",
    7 => "Online Custom",
    8 => "Online League",
    11 => "Career Invitational",
    12 => "Championship Invitational",
    13 => "Championship",
    14 => "Online Championship",
    15 => "Online Weekly Event",
    19 => "Career '22",
    20 => "Career '22 Online",
    127 => "Benchmark",
  }

  @ruleset_ids %{
    0 => "Practice & Qualifying",
    1 => "Race",
    2 => "Time Trial",
    4 => "Time Attack",
    6 => "Checkpoint Challenge",
    8 => "Autocross",
    9 => "Drift",
    10 => "Average Speed Zone",
    11 => "Rival Duel",
  }

  @track_ids %{
    0 => "Melbourne",
    1 => "Paul Ricard",
    2 => "Shanghai",
    3 => "Sakhir (Bahrain)",
    4 => "Catalunya",
    5 => "Monaco",
    6 => "Montreal",
    7 => "Silverstone",
    8 => "Hockenheim",
    9 => "Hungaroring",
    10 => "Spa",
    11 => "Monza",
    12 => "Singapore",
    13 => "Suzuka",
    14 => "Abu Dhabi",
    15 => "Texas",
    16 => "Brazil",
    17 => "Austria",
    18 => "Sochi",
    19 => "Mexico",
    20 => "Baku (Azerbaijan)",
    21 => "Sakhir Short",
    22 => "Silverstone Short",
    23 => "Texas Short",
    24 => "Suzuka Short",
    25 => "Hanoi",
    26 => "Zandvoort",
    27 => "Imola",
    28 => "Portimão",
    29 => "Jeddah",
    30 => "Miami",
  }

  @safety_car_status_ids %{
    0 => "no safety car",
    1 => "full",
    2 => "virtual",
    3 => "formation lap",
  }

  @network_game_ids %{
    0 => "offline",
    1 => "online",
  }

  @forecast_accuracy_ids %{
    0 => "Perfect",
    1 => "Approximate",
  }

  @dynamic_racing_line_ids %{
    0 => "off",
    1 => "corners only",
    2 => "full",
  }

  @session_length_ids %{
    0 => "None",
    2 => "Very Short",
    3 => "Short",
    4 => "Medium",
    5 => "Medium Long",
    6 => "Long",
    7 => "Full",
  }

  defstruct [
    # original
    m_header: nil,                     # header
    m_weather: nil,                    # uint8 - Weather - 0 = clear, 1 = light cloud, 2 = overcast
    m_trackTemperature: nil,           # int8 - Track temp. in degrees celsius
    m_airTemperature: nil,             # int8 - Air temp. in degrees celsius
    m_totalLaps: nil,                  # uint8 - Total number of laps in this race
    m_trackLength: nil,                # uint16 - Track length in metres
    m_sessionType: nil,                # uint8 - 0 = unknown, 1 = P1, 2 = P2, 3 = P3, 4 = Short P
                                       #         5 = Q1, 6 = Q2, 7 = Q3, 8 = Short Q, 9 = OSQ
                                       #         10 = R, 11 = R2, 12 = R3, 13 = Time Trial
    m_trackId: nil,                    # int8 - -1 for unknown, see appendix
    m_formula: nil,                    # uint8 - Formula, 0 = F1 Modern, 1 = F1 Classic, 2 = F2,
                                       #         3 = F1 Generic, 4 = Beta, 5 = Supercars
    m_sessionTimeLeft: nil,            # uint16 - Time left in session in seconds
    m_sessionDuration: nil,            # uint16 - Session duration in seconds
    m_pitSpeedLimit: nil,              # uint8 - Pit speed limit in kilometres per hour
    m_gamePaused: nil,                 # uint8 - Whether the game is paused – network game only
    m_isSpectating: nil,               # uint8 - Whether the player is spectating
    m_spectatorCarIndex: nil,          # uint8 - Index of the car being spectated
    m_sliProNativeSupport: nil,        # uint8 - SLI Pro support, 0 = inactive, 1 = active
    m_numMarshalZones: nil,            # uint8 - Number of marshal zones to follow
    m_marshalZones: nil,               # MarshalZone - List of marshal zones – max 21
    m_safetyCarStatus: nil,            # uint8 - 0 = no safety car, 1 = full, 2 = virtual, 3 = formation lap
    m_networkGame: nil,                # uint8 - 0 = offline, 1 = online
    m_numWeatherForecastSamples: nil,  # uint8 - Number of weather samples to follow
    m_weatherForecastSamples: nil,     # WeatherForecastSample[56] - Array of weather forecast samples
    m_forecastAccuracy: nil,           # uint8 - 0 = Perfect, 1 = Approximate
    m_aiDifficulty: nil,               # uint8 - AI Difficulty rating – 0-110
    m_seasonLinkIdentifier: nil,       # uint32 - Identifier for season - persists across saves
    m_weekendLinkIdentifier: nil,      # uint32 - Identifier for weekend - persists across saves
    m_sessionLinkIdentifier: nil,      # uint32 - Identifier for session - persists across saves
    m_pitStopWindowIdealLap: nil,      # uint8 - Ideal lap to pit on for current strategy (player)
    m_pitStopWindowLatestLap: nil,     # uint8 - Latest lap to pit on for current strategy (player)
    m_pitStopRejoinPosition: nil,      # uint8 - Predicted position to rejoin at (player)
    m_steeringAssist: nil,             # uint8 - 0 = off, 1 = on
    m_brakingAssist: nil,              # uint8 - 0 = off, 1 = low, 2 = medium, 3 = high
    m_gearboxAssist: nil,              # uint8 - 1 = manual, 2 = manual & suggested gear, 3 = auto
    m_pitAssist: nil,                  # uint8 - 0 = off, 1 = on
    m_pitReleaseAssist: nil,           # uint8 - 0 = off, 1 = on
    m_ERSAssist: nil,                  # uint8 - 0 = off, 1 = on
    m_DRSAssist: nil,                  # uint8 - 0 = off, 1 = on
    m_dynamicRacingLine: nil,          # uint8 - 0 = off, 1 = corners only, 2 = full
    m_dynamicRacingLineType: nil,      # uint8 - 0 = 2D, 1 = 3D
    m_gameMode: nil,                   # uint8 - Game mode id - see appendix
    m_ruleSet: nil,                    # uint8 - Ruleset - see appendix
    m_timeOfDay: nil,                  # uint32 - Local time of day - minutes since midnight
    m_sessionLength: nil,              # uint8 - 0 = None, 2 = Very Short, 3 = Short, 4 = Medium
                                       #         5 = Medium Long, 6 = Long, 7 = Full

    # computed
    session_type: nil,
    formula: nil,
    track: nil,
    safety_car_status: nil,
    network_game: nil,
    forecast_accuracy: nil,
    game_mode: nil,
    dynamic_racing_line: nil,
    ruleset: nil,
    session_length: nil,
  ]

  def from_binary(%F122PacketHeader{packet_type: "session"} = ph0, <<
    m_weather::unsigned-little-integer-size(8),
    m_trackTemperature::little-integer-size(8),
    m_airTemperature::little-integer-size(8),
    m_totalLaps::unsigned-little-integer-size(8),
    m_trackLength::unsigned-little-integer-size(16),
    m_sessionType::unsigned-little-integer-size(8),
    m_trackId::little-integer-size(8),
    m_formula::unsigned-little-integer-size(8),
    m_sessionTimeLeft::unsigned-little-integer-size(16),
    m_sessionDuration::unsigned-little-integer-size(16),
    m_pitSpeedLimit::unsigned-little-integer-size(8),
    m_gamePaused::unsigned-little-integer-size(8),
    m_isSpectating::unsigned-little-integer-size(8),
    m_spectatorCarIndex::unsigned-little-integer-size(8),
    m_sliProNativeSupport::unsigned-little-integer-size(8),
    m_numMarshalZones::unsigned-little-integer-size(8),
    m_marshalZones::binary-size(105),
    m_safetyCarStatus::unsigned-little-integer-size(8),
    m_networkGame::unsigned-little-integer-size(8),
    m_numWeatherForecastSamples::unsigned-little-integer-size(8),
    m_weatherForecastSamples::binary-size(448),
    m_forecastAccuracy::unsigned-little-integer-size(8),
    m_aiDifficulty::unsigned-little-integer-size(8),
    m_seasonLinkIdentifier::unsigned-little-integer-size(32),
    m_weekendLinkIdentifier::unsigned-little-integer-size(32),
    m_sessionLinkIdentifier::unsigned-little-integer-size(32),
    m_pitStopWindowIdealLap::unsigned-little-integer-size(8),
    m_pitStopWindowLatestLap::unsigned-little-integer-size(8),
    m_pitStopRejoinPosition::unsigned-little-integer-size(8),
    m_steeringAssist::unsigned-little-integer-size(8),
    m_brakingAssist::unsigned-little-integer-size(8),
    m_gearboxAssist::unsigned-little-integer-size(8),
    m_pitAssist::unsigned-little-integer-size(8),
    m_pitReleaseAssist::unsigned-little-integer-size(8),
    m_ERSAssist::unsigned-little-integer-size(8),
    m_DRSAssist::unsigned-little-integer-size(8),
    m_dynamicRacingLine::unsigned-little-integer-size(8),
    m_dynamicRacingLineType::unsigned-little-integer-size(8),
    m_gameMode::unsigned-little-integer-size(8),
    m_ruleSet::unsigned-little-integer-size(8),
    m_timeOfDay::unsigned-little-integer-size(32),
    m_sessionLength::unsigned-little-integer-size(8),
  >>) do
    with {:ok, marshal_zones} <- fetch_marshal_zones(m_marshalZones, m_numMarshalZones),
      {:ok, weather_forecast_samples} <- fetch_weather_forecast_samples(m_weatherForecastSamples, m_numWeatherForecastSamples)
    do
      {:ok, %__MODULE__{
        m_header: ph0,
        m_weather: m_weather,
        m_trackTemperature: m_trackTemperature,
        m_airTemperature: m_airTemperature,
        m_totalLaps: m_totalLaps,
        m_trackLength: m_trackLength,
        m_sessionType: m_sessionType,
        m_trackId: m_trackId,
        m_formula: m_formula,
        m_sessionTimeLeft: m_sessionTimeLeft,
        m_sessionDuration: m_sessionDuration,
        m_pitSpeedLimit: m_pitSpeedLimit,
        m_gamePaused: m_gamePaused,
        m_isSpectating: m_isSpectating,
        m_spectatorCarIndex: m_spectatorCarIndex,
        m_sliProNativeSupport: m_sliProNativeSupport,
        m_numMarshalZones: m_numMarshalZones,
        m_marshalZones: marshal_zones,
        m_safetyCarStatus: m_safetyCarStatus,
        m_networkGame: m_networkGame,
        m_numWeatherForecastSamples: m_numWeatherForecastSamples,
        m_weatherForecastSamples: weather_forecast_samples,
        m_forecastAccuracy: m_forecastAccuracy,
        m_aiDifficulty: m_aiDifficulty,
        m_seasonLinkIdentifier: m_seasonLinkIdentifier,
        m_weekendLinkIdentifier: m_weekendLinkIdentifier,
        m_sessionLinkIdentifier: m_sessionLinkIdentifier,
        m_pitStopWindowIdealLap: m_pitStopWindowIdealLap,
        m_pitStopWindowLatestLap: m_pitStopWindowLatestLap,
        m_pitStopRejoinPosition: m_pitStopRejoinPosition,
        m_steeringAssist: m_steeringAssist,
        m_brakingAssist: m_brakingAssist,
        m_gearboxAssist: m_gearboxAssist,
        m_pitAssist: m_pitAssist,
        m_pitReleaseAssist: m_pitReleaseAssist,
        m_ERSAssist: m_ERSAssist,
        m_DRSAssist: m_DRSAssist,
        m_dynamicRacingLine: m_dynamicRacingLine,
        m_dynamicRacingLineType: m_dynamicRacingLineType,
        m_gameMode: m_gameMode,
        m_ruleSet: m_ruleSet,
        m_timeOfDay: m_timeOfDay,
        m_sessionLength: m_sessionLength,

        session_type: Map.get(@session_type_ids, m_sessionType),
        formula: Map.get(@formula_ids, m_formula),
        track: Map.get(@track_ids, m_trackId),
        safety_car_status: Map.get(@safety_car_status_ids, m_safetyCarStatus),
        network_game: Map.get(@network_game_ids, m_networkGame),
        forecast_accuracy: Map.get(@forecast_accuracy_ids, m_forecastAccuracy),
        dynamic_racing_line: Map.get(@dynamic_racing_line_ids, m_dynamicRacingLine),
        game_mode: Map.get(@game_mode_ids, m_gameMode),
        ruleset: Map.get(@ruleset_ids, m_ruleSet),
        session_length: Map.get(@session_length_ids, m_sessionLength),
      }}
    end
  end
  def from_binary(%F122PacketHeader{packet_type: "session"} = ph0, data) do
    Logger.warn("data_bytes_size=#{byte_size(data)}")  # FIXME
    {:error, "invalid session packet"}
  end

  @doc false
  def fetch_marshal_zones(data, item_count) do
    with {:ok, items} <- split_marshal_zones(data, item_count, []),
      do: {:ok, items}
  end

  @doc false
  def split_marshal_zones(_data, 0, accum) do
    {:ok, Enum.reverse(accum)}
  end
  def split_marshal_zones(<<item::binary-size(5), rest::binary>>, count, accum) do
    with {:ok, item} <- F122PacketSessionMarshalZone.from_binary(item),
      do: split_marshal_zones(rest, count-1, [item|accum])
  end

  @doc false
  def fetch_weather_forecast_samples(data, item_count) do
    with {:ok, items} <- split_weather_forecast_samples(data, item_count, []),
      do: {:ok, items}
  end

  @doc false
  def split_weather_forecast_samples(_data, 0, accum) do
    {:ok, Enum.reverse(accum)}
  end
  def split_weather_forecast_samples(<<item::binary-size(8), rest::binary>>, count, accum) do
    with {:ok, item} <- F122PacketSessionWeatherForecast.from_binary(item),
      do: split_weather_forecast_samples(rest, count-1, [item|accum])
  end

end

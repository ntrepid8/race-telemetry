defmodule RacingTelemetry.Repo.Migrations.CreateF122SessionPackets do
  use Ecto.Migration

  def change do
    # create table
    create table(:f1_22_session_packets, primary_key: false) do
      # system fields (general meta-data)
      add :id, :binary_id, primary_key: true
      add :serial_number, :bigserial, null: false
      add :iteration, :integer, null: false, default: 0
      add :deleted, :boolean, default: false, null: false
      add :live_mode, :boolean, default: true, null: false
      timestamps()

      # original fields
      add :m_weather, :integer
      add :m_trackTemperature, :integer
      add :m_airTemperature, :integer
      add :m_totalLaps, :integer
      add :m_trackLength, :integer
      add :m_sessionType, :integer
      add :m_trackId, :integer
      add :m_formula, :integer
      add :m_sessionTimeLeft, :integer
      add :m_sessionDuration, :integer
      add :m_pitSpeedLimit, :integer
      add :m_gamePaused, :integer
      add :m_isSpectating, :integer
      add :m_spectatorCarIndex, :integer
      add :m_sliProNativeSupport, :integer
      add :m_numMarshalZones, :integer
      add :m_safetyCarStatus, :integer
      add :m_networkGame, :integer
      add :m_numWeatherForecastSamples, :integer
      add :m_forecastAccuracy, :integer
      add :m_aiDifficulty, :integer
      add :m_seasonLinkIdentifier, :bigint
      add :m_weekendLinkIdentifier, :bigint
      add :m_sessionLinkIdentifier, :bigint
      add :m_pitStopWindowIdealLap, :integer
      add :m_pitStopWindowLatestLap, :integer
      add :m_pitStopRejoinPosition, :integer
      add :m_steeringAssist, :integer
      add :m_brakingAssist, :integer
      add :m_gearboxAssist, :integer
      add :m_pitAssist, :integer
      add :m_pitReleaseAssist, :integer
      add :m_ERSAssist, :integer
      add :m_DRSAssist, :integer
      add :m_dynamicRacingLine, :integer
      add :m_dynamicRacingLineType, :integer
      add :m_gameMode, :integer
      add :m_ruleSet, :integer
      add :m_timeOfDay, :bigint
      add :m_sessionLength, :integer

      # extra
      add :session_type, :string
      add :formula, :string
      add :track, :string
      add :safety_car_status, :string
      add :network_game, :string
      add :forecast_accuracy, :string
      add :game_mode, :string
      add :dynamic_racing_line, :string
      add :ruleset, :string
      add :session_length, :string

      # associations
      add :m_header_id, references(:f1_22_packet_headers, on_delete: :delete_all, type: :binary_id), null: false
    end

    # system indexes
    create index(:f1_22_session_packets, [:deleted])
    create index(:f1_22_session_packets, [:live_mode])
    create index(:f1_22_session_packets, [:inserted_at])
    create index(:f1_22_session_packets, [:updated_at])
    create index(:f1_22_session_packets, [:serial_number], unique: true)

  end

end

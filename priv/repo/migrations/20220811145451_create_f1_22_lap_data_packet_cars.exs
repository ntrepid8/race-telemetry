defmodule RacingTelemetry.Repo.Migrations.CreateF122LapDataPacketCars do
  use Ecto.Migration

  def change do
    # create table
    create table(:f1_22_lap_data_packet_cars, primary_key: false) do
      # system fields (general meta-data)
      add :id, :binary_id, primary_key: true
      add :serial_number, :bigserial, null: false
      add :iteration, :integer, null: false, default: 0
      add :deleted, :boolean, default: false, null: false
      add :live_mode, :boolean, default: true, null: false
      timestamps()

      # model fields
      add :m_lastLapTimeInMS, :bigint
      add :m_currentLapTimeInMS, :bigint
      add :m_sector1TimeInMS, :integer
      add :m_sector2TimeInMS, :integer
      add :m_lapDistance, :float
      add :m_totalDistance, :float
      add :m_safetyCarDelta, :float
      add :m_carPosition, :integer
      add :m_currentLapNum, :integer
      add :m_pitStatus, :integer
      add :m_numPitStops, :integer
      add :m_sector, :integer
      add :m_currentLapInvalid, :integer
      add :m_penalties, :integer
      add :m_warnings, :integer
      add :m_numUnservedDriveThroughPens, :integer
      add :m_numUnservedStopGoPens, :integer
      add :m_gridPosition, :integer
      add :m_driverStatus, :integer
      add :m_resultStatus, :integer
      add :m_pitLaneTimerActive, :integer
      add :m_pitLaneTimeInLaneInMS, :integer
      add :m_pitStopTimerInMS, :integer
      add :m_pitStopShouldServePen, :integer
      add :car_index, :integer
      add :pit_status, :string
      add :sector, :integer
      add :current_lap_invalid, :string
      add :driver_status, :string
      add :result_status, :string
      add :pit_lane_timer_active, :string

      # associations
      add :f1_22_lap_data_packet_id, references(:f1_22_lap_data_packets, on_delete: :delete_all, type: :binary_id), null: false
    end

    # system indexes
    create index(:f1_22_lap_data_packet_cars, [:deleted])
    create index(:f1_22_lap_data_packet_cars, [:live_mode])
    create index(:f1_22_lap_data_packet_cars, [:inserted_at])
    create index(:f1_22_lap_data_packet_cars, [:updated_at])
    create index(:f1_22_lap_data_packet_cars, [:serial_number], unique: true)

    # lookup indexes
    create index(:f1_22_lap_data_packet_cars, [:car_index])
    create index(:f1_22_lap_data_packet_cars, [:m_lapDistance])
    create index(:f1_22_lap_data_packet_cars, [:m_totalDistance])

  end

end

defmodule RacingTelemetry.Repo.Migrations.CreateF122CarTelemetryPacketCars do
  use Ecto.Migration

  def change do
    # create table
    create table(:f1_22_car_telemetry_packet_cars, primary_key: false) do
      # system fields (general meta-data)
      add :id, :binary_id, primary_key: true
      add :serial_number, :bigserial, null: false
      add :iteration, :integer, null: false, default: 0
      add :deleted, :boolean, default: false, null: false
      add :live_mode, :boolean, default: true, null: false
      timestamps()

      # header fields (for indexing)
      add :m_sessionUID, :numeric, precision: 20, scale: 0  # uint64
      add :m_sessionTime, :float
      add :m_frameIdentifier, :bigint

      # model fields
      add :m_speed, :integer
      add :m_throttle, :float
      add :m_steer, :float
      add :m_brake, :float
      add :m_clutch, :integer
      add :m_gear, :integer
      add :m_engineRPM, :integer
      add :m_drs, :integer
      add :m_revLightsPercent, :integer
      add :m_revLightsBitValue, :integer
      add :m_brakesTemperature, {:array, :integer}
      add :m_tyresSurfaceTemperature, {:array, :integer}
      add :m_tyresInnerTemperature, {:array, :integer}
      add :m_engineTemperature, :integer
      add :m_tyresPressure, {:array, :float}
      add :m_surfaceType, {:array, :integer}
      add :car_index, :integer
      add :surface_type, {:array, :string}

      # associations
      add :f1_22_car_telemetry_packet_id,
        references(:f1_22_car_telemetry_packets, on_delete: :delete_all, type: :binary_id),
        null: false
    end

    # system indexes
    create index(:f1_22_car_telemetry_packet_cars, [:deleted])
    create index(:f1_22_car_telemetry_packet_cars, [:live_mode])
    create index(:f1_22_car_telemetry_packet_cars, [:inserted_at])
    create index(:f1_22_car_telemetry_packet_cars, [:updated_at])
    create index(:f1_22_car_telemetry_packet_cars, [:serial_number], unique: true)

    # lookup indexes
    create index(:f1_22_car_telemetry_packet_cars, [:car_index])

    # header indexes
    create index(:f1_22_car_telemetry_packet_cars, [:m_sessionUID])
    create index(:f1_22_car_telemetry_packet_cars, [:m_sessionTime])
    create index(:f1_22_car_telemetry_packet_cars, [:m_frameIdentifier])

  end

end

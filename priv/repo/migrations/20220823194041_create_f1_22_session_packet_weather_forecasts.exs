defmodule RacingTelemetry.Repo.Migrations.CreateF122SessionPacketWeatherForecasts do
  use Ecto.Migration

  def change do
    # create table
    create table(:f1_22_session_packet_weather_forecasts, primary_key: false) do
      # system fields (general meta-data)
      add :id, :binary_id, primary_key: true
      add :serial_number, :bigserial, null: false
      add :iteration, :integer, null: false, default: 0
      add :deleted, :boolean, default: false, null: false
      add :live_mode, :boolean, default: true, null: false
      timestamps()

      # model fields
      add :m_sessionType, :integer
      add :m_timeOffset, :integer
      add :m_weather, :integer
      add :m_trackTemperature, :integer
      add :m_trackTemperatureChange, :integer
      add :m_airTemperature, :integer
      add :m_airTemperatureChange, :integer
      add :m_rainPercentage, :integer

      # associations
      add :f1_22_session_packet_id,
        references(:f1_22_session_packets, on_delete: :delete_all, type: :binary_id),
        null: false
    end

    # system indexes
    create index(:f1_22_session_packet_weather_forecasts, [:deleted])
    create index(:f1_22_session_packet_weather_forecasts, [:live_mode])
    create index(:f1_22_session_packet_weather_forecasts, [:inserted_at])
    create index(:f1_22_session_packet_weather_forecasts, [:updated_at])
    create index(:f1_22_session_packet_weather_forecasts, [:serial_number], unique: true)

  end
end

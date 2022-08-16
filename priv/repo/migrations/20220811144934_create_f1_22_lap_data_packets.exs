defmodule RacingTelemetry.Repo.Migrations.CreateF122LapDataPackets do
  use Ecto.Migration

  def change do
    # create table
    create table(:f1_22_lap_data_packets, primary_key: false) do
      # system fields (general meta-data)
      add :id, :binary_id, primary_key: true
      add :serial_number, :bigserial, null: false
      add :iteration, :integer, null: false, default: 0
      add :deleted, :boolean, default: false, null: false
      add :live_mode, :boolean, default: true, null: false
      timestamps()

      # model fields
      add :m_timeTrialPBCarIdx, :integer
      add :m_timeTrialRivalCarIdx, :integer

      # associations
      add :m_header_id, references(:f1_22_packet_headers, on_delete: :delete_all, type: :binary_id), null: false
    end

    # system indexes
    create index(:f1_22_lap_data_packets, [:deleted])
    create index(:f1_22_lap_data_packets, [:live_mode])
    create index(:f1_22_lap_data_packets, [:inserted_at])
    create index(:f1_22_lap_data_packets, [:updated_at])
    create index(:f1_22_lap_data_packets, [:serial_number], unique: true)

  end

end

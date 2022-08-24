defmodule RacingTelemetry.Repo.Migrations.CreateF122SessionPacketMarshalZones do
  use Ecto.Migration

  def change do
    # create table
    create table(:f1_22_session_packet_marshal_zones, primary_key: false) do
      # system fields (general meta-data)
      add :id, :binary_id, primary_key: true
      add :serial_number, :bigserial, null: false
      add :iteration, :integer, null: false, default: 0
      add :deleted, :boolean, default: false, null: false
      add :live_mode, :boolean, default: true, null: false
      timestamps()

      # model fields
      add :m_zoneStart, :float
      add :m_zoneFlag, :integer

      # associations
      add :f1_22_session_packet_id,
        references(:f1_22_session_packets, on_delete: :delete_all, type: :binary_id),
        null: false
    end

    # system indexes
    create index(:f1_22_session_packet_marshal_zones, [:deleted])
    create index(:f1_22_session_packet_marshal_zones, [:live_mode])
    create index(:f1_22_session_packet_marshal_zones, [:inserted_at])
    create index(:f1_22_session_packet_marshal_zones, [:updated_at])
    create index(:f1_22_session_packet_marshal_zones, [:serial_number], unique: true)

  end
end

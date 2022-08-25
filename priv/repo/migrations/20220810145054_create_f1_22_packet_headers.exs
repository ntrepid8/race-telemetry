defmodule RacingTelemetry.Repo.Migrations.CreateF122PacketHeaders do
  use Ecto.Migration

  def change do
    # create table
    create table(:f1_22_packet_headers, primary_key: false) do
      # system fields (general meta-data)
      add :id, :binary_id, primary_key: true
      add :serial_number, :bigserial, null: false
      add :iteration, :integer, null: false, default: 0
      add :deleted, :boolean, default: false, null: false
      add :live_mode, :boolean, default: true, null: false
      timestamps()

      # model fields
      add :m_packetFormat, :integer
      add :m_gameMajorVersion, :integer
      add :m_gameMinorVersion, :integer
      add :m_packetVersion, :integer
      add :m_packetId, :integer
      add :m_sessionUID, :numeric, precision: 20, scale: 0  # uint64
      add :m_sessionTime, :float
      add :m_frameIdentifier, :bigint
      add :m_playerCarIndex, :integer
      add :m_secondaryPlayerCarIndex, :integer
      add :packet_type, :string
    end

    # system indexes
    create index(:f1_22_packet_headers, [:deleted])
    create index(:f1_22_packet_headers, [:live_mode])
    create index(:f1_22_packet_headers, [:inserted_at])
    create index(:f1_22_packet_headers, [:updated_at])
    create index(:f1_22_packet_headers, [:serial_number], unique: true)

    # lookup indexes
    create index(:f1_22_packet_headers, [:m_packetId])
    create index(:f1_22_packet_headers, [:m_sessionUID])
    create index(:f1_22_packet_headers, [:m_sessionTime])
    create index(:f1_22_packet_headers, [:m_frameIdentifier])
    create index(:f1_22_packet_headers, [:packet_type])
    create index(:f1_22_packet_headers, [:m_frameIdentifier, :m_sessionTime])
  end

end

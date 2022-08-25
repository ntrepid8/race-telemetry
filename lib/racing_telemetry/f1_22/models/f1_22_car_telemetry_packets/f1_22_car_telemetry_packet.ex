defmodule RacingTelemetry.F122.Models.F122CarTelemetryPackets.F122CarTelemetryPacket do
  use RacingTelemetry.Schema
  require Logger
  alias RacingTelemetry, as: RT

  # fields that must always be present
  @required_fields [
    # original
    :m_mfdPanelIndex,
    :m_mfdPanelIndexSecondaryPlayer,
    :m_suggestedGear,

    # extra
    :mfd_panel,
    :mfd_panel_secondary_player,

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
  ] ++ @system_fields ++ @required_fields

  @exclude_from_json_fields [
    :__meta__,
    :deleted,
    :iteration,
    :serial_number,
  ]

  @derive {Jason.Encoder, except: @exclude_from_json_fields}
  schema "f1_22_car_telemetry_packets" do
    field :object, :string, virtual: true, default: "f1_22_car_telemetry_packet"

    # header fields (for indexing)
    field :m_sessionUID, :decimal       # uint64  - Unique identifier for the session
    field :m_sessionTime, :float        # float32 - Session timestamp (seconds since the session started)
    field :m_frameIdentifier, :integer  # uint32  - Identifier for the frame the data was retrieved on

    # original fields
    field :m_mfdPanelIndex, :integer                 # uint8 - Index of MFD panel open
    field :m_mfdPanelIndexSecondaryPlayer, :integer  # uint8
    field :m_suggestedGear, :integer                 # int8

    # extra fields
    field :mfd_panel, :string
    field :mfd_panel_secondary_player, :string

    # associations
    belongs_to :m_header, RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader
    has_many :m_carTelemetryData, RacingTelemetry.F122.Models.F122CarTelemetryPackets.F122CarTelemetryPacketCar,
      foreign_key: :f1_22_car_telemetry_packet_id,
      preload_order: [asc: :car_index]

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
    |> cast_assoc(:m_header, with: &RT.F122.Models.F122PacketHeaders.F122PacketHeader.changeset/2)
    |> cast_assoc(:m_carTelemetryData, with: &RT.F122.Models.F122CarTelemetryPackets.F122CarTelemetryPacketCar.changeset/2)
  end

end

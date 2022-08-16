defmodule RacingTelemetry.F122.Models.F122LapDataPackets.F122LapDataPacket do
  use RacingTelemetry.Schema
  require Logger

  # fields that must always be present
  @required_fields [
    :m_timeTrialPBCarIdx,
    :m_timeTrialRivalCarIdx,
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
  schema "f1_22_lap_data_packets" do
    field :object, :string, virtual: true, default: "f1_22_lap_data_packet"

    # original fields
    field :m_timeTrialPBCarIdx, :integer     # uint8 - Index of Personal Best car in time trial (255 if invalid)
    field :m_timeTrialRivalCarIdx, :integer  # uint8 - Index of Rival car in time trial (255 if invalid)

    # extra fields

    # associations
    belongs_to :m_header, RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader
    has_many :m_lapData, RacingTelemetry.F122.Models.F122LapDataPackets.F122LapDataPacketCar,
      foreign_key: :f1_22_lap_data_packet_id,
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
    |> cast_assoc(:m_header, with: &RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader.changeset/2)
    |> cast_assoc(:m_lapData, with: &RacingTelemetry.F122.Models.F122LapDataPackets.F122LapDataPacketCar.changeset/2)
  end

end

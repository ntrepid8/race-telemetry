defmodule RacingTelemetry.F122.Models.F122SessionPackets.F122SessionPacketMarshalZone do
  use RacingTelemetry.Schema
  require Logger

  # fields that must always be present
  @required_fields [
    # original fields
    :m_zoneStart,
    :m_zoneFlag,
  ]

  # fields used by the system which are present on all record types
  @system_fields [
    :deleted,
    :live_mode,
  ]

  # fields that are permitted to change on "update" operations
  @permitted_fields [
    # associations
    :f1_22_session_packet_id,
  ] ++ @system_fields ++ @required_fields

  @exclude_from_json_fields [
    :__meta__,
    :deleted,
    :iteration,
    :serial_number,
  ]

  @derive {Jason.Encoder, except: @exclude_from_json_fields}
  schema "f1_22_session_packet_marshal_zones" do
    field :object, :string, virtual: true, default: "f1_22_session_packet_marshal_zone"

    # original fields
    field :m_zoneStart, :float   # float32 - Fraction (0..1) of way through the lap the marshal zone starts
    field :m_zoneFlag, :integer  # int8 - -1 = invalid/unknown, 0 = none, 1 = green, 2 = blue, 3 = yellow, 4 = red

    # extra fields

    # associations
    belongs_to :f1_22_session_packet, RacingTelemetry.F122.Packets.F122PacketSession
    has_one :m_header, through: [:f1_22_session_packet, :m_header]

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
  end

end

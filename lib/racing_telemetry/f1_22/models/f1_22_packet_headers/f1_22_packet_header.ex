defmodule RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader do
  use RacingTelemetry.Schema
  require Logger

  # fields that must always be present
  @required_fields [
    :m_packetFormat,
    :m_gameMajorVersion,
    :m_gameMinorVersion,
    :m_packetVersion,
    :m_packetId,
    :m_sessionUID,
    :m_sessionTime,
    :m_frameIdentifier,
    :m_playerCarIndex,
    :m_secondaryPlayerCarIndex,
    :packet_type,
  ]

  # fields used by the system which are present on all record types
  @system_fields [
    :deleted,
    :live_mode,
  ]

  # fields that are permitted to change on "update" operations
  @permitted_fields [
  ] ++ @system_fields ++ @required_fields

  @packet_type_options [
    "motion",
    "session",
    "lap_data",
    "event",
    "participants",
    "car_setups",
    "car_telemetry",
    "car_status",
    "final_classification",
    "lobby_info",
    "car_damage",
    "session_history",
  ]

  @exclude_from_json_fields [
    :__meta__,
    :deleted,
    :iteration,
    :serial_number,
  ]

  @derive {Jason.Encoder, except: @exclude_from_json_fields}
  schema "f1_22_packet_headers" do
    field :object, :string, virtual: true, default: "f1_22_packet_header"

    # original fields
    field :m_packetFormat, :integer             # uint16  - 2022
    field :m_gameMajorVersion, :integer         # uint8   - Game major version -"X.00"
    field :m_gameMinorVersion, :integer         # uint8   - Game minor version -"1.XX"
    field :m_packetVersion, :integer            # uint8   - Version of this packet type, all start from 1
    field :m_packetId, :integer                 # uint8   - Identifier for the packet type, see below
    field :m_sessionUID, :decimal               # uint64  - Unique identifier for the session
    field :m_sessionTime, :float                # float32 - Session timestamp (seconds since the session started)
    field :m_frameIdentifier, :integer          # uint32  - Identifier for the frame the data was retrieved on
    field :m_playerCarIndex, :integer           # uint8   - Index of player's car in the array
    field :m_secondaryPlayerCarIndex, :integer  # uint8   - Index of 2nd player's car in the array, 255 if no 2nd player

    # extra fields
    field :packet_type, :string

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
    |> validate_inclusion(:packet_type, @packet_type_options)
  end

  @doc """
  Return a list of keys for use as a CSV header.

  """
  def get_csv_header() do
    [
      :m_packetFormat,
      :m_gameMajorVersion,
      :m_gameMinorVersion,
      :m_packetVersion,
      :m_packetId,
      :m_sessionUID,
      :m_sessionTime,
      :m_frameIdentifier,
      :m_playerCarIndex,
      :m_secondaryPlayerCarIndex,
      :packet_type,
    ]
  end

  @doc """
  Output as a list of values for use as a row in a CSV.

  """
  def to_csv_row(%__MODULE__{} = data) do
    get_csv_header()
    |> Enum.map(fn key -> Map.get(data, key) end)
  end

end

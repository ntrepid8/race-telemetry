defmodule RacingTelemetry.F122.Models.F122SessionPackets.F122SessionPacketWeatherForecast do
  use RacingTelemetry.Schema
  require Logger

  # fields that must always be present
  @required_fields [
    # original fields
    :m_sessionType,
    :m_timeOffset,
    :m_weather,
    :m_trackTemperature,
    :m_trackTemperatureChange,
    :m_airTemperature,
    :m_airTemperatureChange,
    :m_rainPercentage,
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
  schema "f1_22_session_packet_weather_forecasts" do
    field :object, :string, virtual: true, default: "f1_22_session_packet_weather_forecast"

    # original fields
    field :m_sessionType, :integer              # uint8 - 0 = unknown, 1 = P1, 2 = P2, 3 = P3, 4 = Short P, 5 = Q1
                                                #         6 = Q2, 7 = Q3, 8 = Short Q, 9 = OSQ, 10 = R, 11 = R2
                                                #         12 = R3, 13 = Time Trial
    field :m_timeOffset, :integer               # uint8 - Time in minutes the forecast is for
    field :m_weather, :integer                  # uint8 - Weather - 0 = clear, 1 = light cloud, 2 = overcast
    field :m_trackTemperature, :integer         # int8 - Track temp. in degrees Celsius
    field :m_trackTemperatureChange, :integer   # int8 - Track temp. change – 0 = up, 1 = down, 2 = no change
    field :m_airTemperature, :integer           # int8 - Air temp. in degrees celsius
    field :m_airTemperatureChange, :integer     # int8 - Air temp. change – 0 = up, 1 = down, 2 = no change
    field :m_rainPercentage, :integer           # uint8 - Rain percentage (0-100)

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

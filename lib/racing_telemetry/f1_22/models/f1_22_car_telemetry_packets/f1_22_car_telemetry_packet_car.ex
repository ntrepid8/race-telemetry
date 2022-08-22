defmodule RacingTelemetry.F122.Models.F122CarTelemetryPackets.F122CarTelemetryPacketCar do
  use RacingTelemetry.Schema
  require Logger
  alias RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader

  # fields that must always be present
  @required_fields [
    # original fields
    :m_speed,
    :m_throttle,
    :m_steer,
    :m_brake,
    :m_clutch,
    :m_gear,
    :m_engineRPM,
    :m_drs,
    :m_revLightsPercent,
    :m_revLightsBitValue,
    :m_brakesTemperature,
    :m_tyresSurfaceTemperature,
    :m_tyresInnerTemperature,
    :m_engineTemperature,
    :m_tyresPressure,
    :m_surfaceType,

    # extrafields
    :car_index,
    :surface_type,
  ]

  # fields used by the system which are present on all record types
  @system_fields [
    :deleted,
    :live_mode,
  ]

  # fields that are permitted to change on "update" operations
  @permitted_fields [
    # associations
    :f1_22_car_telemetry_packet_id,
  ] ++ @system_fields ++ @required_fields

  @exclude_from_json_fields [
    :__meta__,
    :deleted,
    :iteration,
    :serial_number,
  ]

  @derive {Jason.Encoder, except: @exclude_from_json_fields}
  schema "f1_22_car_telemetry_packet_cars" do
    field :object, :string, virtual: true, default: "f1_22_car_telemetry_packet_car"

    # original fields
    field :m_speed, :integer                              # uint16 - Speed of car in kilometres per hour
    field :m_throttle, :float                             # float32 - Amount of throttle applied (0.0 to 1.0)
    field :m_steer, :float                                # float32 - Steering (-1.0 (full lock left) to 1.0 (full lock right))
    field :m_brake, :float                                # float32 - Amount of brake applied (0.0 to 1.0)
    field :m_clutch, :integer                             # uint8 - mount of clutch applied (0 to 100)
    field :m_gear, :integer                               # int8 - Gear selected (1-8, N=0, R=-1)
    field :m_engineRPM, :integer                          # uint16 - Engine RPM
    field :m_drs, :integer                                # uint8 - 0 = off, 1 = on
    field :m_revLightsPercent, :integer                   # uint8 - Rev lights indicator (percentage)
    field :m_revLightsBitValue, :integer                  # uint16 - Rev lights (bit 0 = leftmost LED, bit 14 = rightmost LED)
    field :m_brakesTemperature, {:array, :integer}        # uint16[4] - Brakes temperature (celsius), RL, RR, FL, FR
    field :m_tyresSurfaceTemperature, {:array, :integer}  # uint8[4] - Tyres surface temperature (celsius), RL, RR, FL, FR
    field :m_tyresInnerTemperature, {:array, :integer}    # uint8[4] - Tyres inner temperature (celsius), RL, RR, FL, FR
    field :m_engineTemperature, :integer                  # uint16 - Engine temperature (celsius)
    field :m_tyresPressure, {:array, :float}              # float32[4] - Tyres pressure (PSI), RL, RR, FL, FR
    field :m_surfaceType, {:array, :integer}              # uint8[4] - see @driving_surface_type, RL, RR, FL, FR

    # extra fields
    field :car_index, :integer
    field :surface_type, {:array, :string}

    # associations
    belongs_to :f1_22_car_telemetry_packet, RacingTelemetry.F122.Models.F122CarTelemetryPackets.F122CarTelemetryPacket
    has_one :m_header, through: [:f1_22_car_telemetry_packet, :m_header]

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

  @doc """
  Return a list of keys for use as a CSV header.

  """
  def get_csv_header() do
    F122PacketHeader.get_csv_header()
    |> Enum.concat([
      # original fields
      :m_speed,
      :m_throttle,
      :m_steer,
      :m_brake,
      :m_clutch,
      :m_gear,
      :m_engineRPM,
      :m_drs,
      :m_revLightsPercent,
      :m_revLightsBitValue,
      :m_brakesTemperature_rl,
      :m_brakesTemperature_rr,
      :m_brakesTemperature_fl,
      :m_brakesTemperature_fr,
      :m_tyresSurfaceTemperature_rl,
      :m_tyresSurfaceTemperature_rr,
      :m_tyresSurfaceTemperature_fl,
      :m_tyresSurfaceTemperature_fr,
      :m_tyresInnerTemperature_rl,
      :m_tyresInnerTemperature_rr,
      :m_tyresInnerTemperature_fl,
      :m_tyresInnerTemperature_fr,
      :m_engineTemperature,
      :m_tyresPressure_rl,
      :m_tyresPressure_rr,
      :m_tyresPressure_fl,
      :m_tyresPressure_fr,
      :m_surfaceType_rl,
      :m_surfaceType_rr,
      :m_surfaceType_fl,
      :m_surfaceType_fr,

      # extrafields
      :car_index,
      :surface_type_rl,
      :surface_type_rr,
      :surface_type_fl,
      :surface_type_fr,
    ])
  end

  @doc """
  Output as a list of values for use as a row in a CSV.

  """
  def to_csv_row(%__MODULE__{m_header: %{object: "f1_22_packet_header"} = m_header} = data) do
    F122PacketHeader.to_csv_row(m_header)
    |> Enum.concat([
      data.m_speed,
      data.m_throttle,
      data.m_steer,
      data.m_brake,
      data.m_clutch,
      data.m_gear,
      data.m_engineRPM,
      data.m_drs,
      data.m_revLightsPercent,
      data.m_revLightsBitValue,
      Enum.at(data.m_brakesTemperature, 0),
      Enum.at(data.m_brakesTemperature, 1),
      Enum.at(data.m_brakesTemperature, 2),
      Enum.at(data.m_brakesTemperature, 3),
      Enum.at(data.m_tyresSurfaceTemperature, 0),
      Enum.at(data.m_tyresSurfaceTemperature, 1),
      Enum.at(data.m_tyresSurfaceTemperature, 2),
      Enum.at(data.m_tyresSurfaceTemperature, 3),
      Enum.at(data.m_tyresInnerTemperature, 0),
      Enum.at(data.m_tyresInnerTemperature, 1),
      Enum.at(data.m_tyresInnerTemperature, 2),
      Enum.at(data.m_tyresInnerTemperature, 3),
      data.m_engineTemperature,
      Enum.at(data.m_tyresPressure, 0),
      Enum.at(data.m_tyresPressure, 1),
      Enum.at(data.m_tyresPressure, 2),
      Enum.at(data.m_tyresPressure, 3),
      Enum.at(data.m_surfaceType, 0),
      Enum.at(data.m_surfaceType, 1),
      Enum.at(data.m_surfaceType, 2),
      Enum.at(data.m_surfaceType, 3),
      data.car_index,
      Enum.at(data.surface_type, 0),
      Enum.at(data.surface_type, 1),
      Enum.at(data.surface_type, 2),
      Enum.at(data.surface_type, 3),
    ])
  end

end

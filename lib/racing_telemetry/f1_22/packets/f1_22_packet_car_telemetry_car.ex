defmodule RacingTelemetry.F122.Packets.F122PacketCarTelemetryCar do
  @moduledoc """
  CarTelemetry information about individual cars on the track.

  Part of F122PacketCarTelemetry structure.

  Size: 480 bits / 60 bytes
  """
  require Logger
  defstruct [
    m_speed: nil,                    # uint16 - Speed of car in kilometres per hour
    m_throttle: nil,                 # float32 - Amount of throttle applied (0.0 to 1.0)
    m_steer: nil,                    # float32 - Steering (-1.0 (full lock left) to 1.0 (full lock right))
    m_brake: nil,                    # float32 - Amount of brake applied (0.0 to 1.0)
    m_clutch: nil,                   # uint8 - mount of clutch applied (0 to 100)
    m_gear: nil,                     # int8 - Gear selected (1-8, N=0, R=-1)
    m_engineRPM: nil,                # uint16 - Engine RPM
    m_drs: nil,                      # uint8 - 0 = off, 1 = on
    m_revLightsPercent: nil,         # uint8 - Rev lights indicator (percentage)
    m_revLightsBitValue: nil,        # uint16 - Rev lights (bit 0 = leftmost LED, bit 14 = rightmost LED)
    m_brakesTemperature: nil,        # uint16[4] - Brakes temperature (celsius), RL, RR, FL, FR
    m_tyresSurfaceTemperature: nil,  # uint8[4] - Tyres surface temperature (celsius), RL, RR, FL, FR
    m_tyresInnerTemperature: nil,    # uint8[4] - Tyres inner temperature (celsius), RL, RR, FL, FR
    m_engineTemperature: nil,        # uint16 - Engine temperature (celsius)
    m_tyresPressure: nil,            # float32[4] - Tyres pressure (PSI), RL, RR, FL, FR
    m_surfaceType: nil,              # uint8[4] - see @driving_surface_type, RL, RR, FL, FR

    # computed
    car_index: nil,
    surface_type: nil,               # RL, RR, FL, FR
  ]

  @driving_surface_type %{
    0 => "Tarmac",
    1 => "Rumble stripe",
    2 => "Concrete",
    3 => "Rock",
    4 => "Gravel",
    5 => "Mud",
    6 => "Sand",
    7 => "Grass",
    8 => "Water",
    9 => "Cobblestone",
    10 => "Metal",
    11 => "Ridged",
  }

  def from_binary(car_index, <<
    m_speed::unsigned-little-integer-size(16),
    m_throttle::little-float-size(32),
    m_steer::little-float-size(32),
    m_brake::little-float-size(32),
    m_clutch::unsigned-little-integer-size(8),
    m_gear::little-integer-size(8),
    m_engineRPM::unsigned-little-integer-size(16),
    m_drs::unsigned-little-integer-size(8),
    m_revLightsPercent::unsigned-little-integer-size(8),
    m_revLightsBitValue::unsigned-little-integer-size(16),  # 176

    # m_brakesTemperature - 64
    m_brakesTemperature_rl::unsigned-little-integer-size(16),
    m_brakesTemperature_rr::unsigned-little-integer-size(16),
    m_brakesTemperature_fl::unsigned-little-integer-size(16),
    m_brakesTemperature_fr::unsigned-little-integer-size(16),

    # m_tyresSurfaceTemperature - 32
    m_tyresSurfaceTemperature_rl::unsigned-little-integer-size(8),
    m_tyresSurfaceTemperature_rr::unsigned-little-integer-size(8),
    m_tyresSurfaceTemperature_fl::unsigned-little-integer-size(8),
    m_tyresSurfaceTemperature_fr::unsigned-little-integer-size(8),

    # m_tyresInnerTemperature - 32
    m_tyresInnerTemperature_rl::unsigned-little-integer-size(8),
    m_tyresInnerTemperature_rr::unsigned-little-integer-size(8),
    m_tyresInnerTemperature_fl::unsigned-little-integer-size(8),
    m_tyresInnerTemperature_fr::unsigned-little-integer-size(8),

    m_engineTemperature::unsigned-little-integer-size(16),

    # m_tyresPressure - 128
    m_tyresPressure_rl::little-float-size(32),
    m_tyresPressure_rr::little-float-size(32),
    m_tyresPressure_fl::little-float-size(32),
    m_tyresPressure_fr::little-float-size(32),

    # m_surfaceType - 32
    m_surfaceType_rl::unsigned-little-integer-size(8),
    m_surfaceType_rr::unsigned-little-integer-size(8),
    m_surfaceType_fl::unsigned-little-integer-size(8),
    m_surfaceType_fr::unsigned-little-integer-size(8),
  >>) do
    {:ok, %__MODULE__{
      # original
      m_speed: m_speed,
      m_throttle: m_throttle,
      m_steer: m_steer,
      m_brake: m_brake,
      m_clutch: m_clutch,
      m_gear: m_gear,
      m_engineRPM: m_engineRPM,
      m_drs: m_drs,
      m_revLightsPercent: m_revLightsPercent,
      m_revLightsBitValue: m_revLightsBitValue,
      m_brakesTemperature: [
        m_brakesTemperature_rl,
        m_brakesTemperature_rr,
        m_brakesTemperature_fl,
        m_brakesTemperature_fr,
      ],
      m_tyresSurfaceTemperature: [
        m_tyresSurfaceTemperature_rl,
        m_tyresSurfaceTemperature_rr,
        m_tyresSurfaceTemperature_fl,
        m_tyresSurfaceTemperature_fr,
      ],
      m_tyresInnerTemperature: [
        m_tyresInnerTemperature_rl,
        m_tyresInnerTemperature_rr,
        m_tyresInnerTemperature_fl,
        m_tyresInnerTemperature_fr,
      ],
      m_engineTemperature: m_engineTemperature,
      m_tyresPressure: [
        m_tyresPressure_rl,
        m_tyresPressure_rr,
        m_tyresPressure_fl,
        m_tyresPressure_fr,
      ],
      m_surfaceType: [
        m_surfaceType_rl,
        m_surfaceType_rr,
        m_surfaceType_fl,
        m_surfaceType_fr,
      ],

      # computed
      car_index: car_index,
      surface_type: [
        Map.get(@driving_surface_type, m_surfaceType_rl, "Unknown"),
        Map.get(@driving_surface_type, m_surfaceType_rr, "Unknown"),
        Map.get(@driving_surface_type, m_surfaceType_fl, "Unknown"),
        Map.get(@driving_surface_type, m_surfaceType_fr, "Unknown"),
      ],
    }}
  end
  def from_binary(car_index, data) do
    Logger.error("car_index=#{car_index} data_byte_size=#{byte_size(data)} data=#{inspect data}")
    {:error, %{packet_car_telemetry_car: ["is invalid"]}}
  end

end

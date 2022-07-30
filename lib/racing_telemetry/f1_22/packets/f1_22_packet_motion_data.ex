defmodule RacingTelemetry.F122.Packets.F122PacketMotionData do
  @moduledoc """
  The motion packet gives physics data for all the cars being driven. There is additional
  data for the car being driven with the goal of being able to drive a motion platform setup.

  size: 1464 bytes

  """
  require Logger
  alias RacingTelemetry.F122.Packets.{
    F122PacketHeader,
    F122PacketMotionCarMotion,
  }

  defstruct [
    # original
    m_header: nil,
    m_carMotionData: nil,           # Data for all cars on track

    # Extra player car ONLY data
    m_suspensionPosition: nil,      # Note: All wheel arrays have the following order:
    m_suspensionVelocity: nil,      # RL, RR, FL, FR
    m_suspensionAcceleration: nil,  # RL, RR, FL, FR
    m_wheelSpeed: nil,              # Speed of each wheel
    m_wheelSlip: nil,               # Slip ratio for each wheel
    m_localVelocityX: nil,          # Velocity in local space
    m_localVelocityY: nil,          # Velocity in local space
    m_localVelocityZ: nil,          # Velocity in local space
    m_angularVelocityX: nil,        # Angular velocity x-component
    m_angularVelocityY: nil,        # Angular velocity y-component
    m_angularVelocityZ: nil,        # Angular velocity z-component
    m_angularAccelerationX: nil,    # Angular acceleration x-component
    m_angularAccelerationY: nil,    # Angular acceleration y-component
    m_angularAccelerationZ: nil,    # Angular acceleration z-component
    m_frontWheelsAngle: nil,        # Current front wheels angle in radians

    # computed
  ]

  def from_binary(%F122PacketHeader{packet_type: "motion"} = ph0, <<
    m_carMotionData::binary-size(1320),
    # m_suspensionPosition
    m_suspensionPosition_rl::little-float-size(32),
    m_suspensionPosition_rr::little-float-size(32),
    m_suspensionPosition_fl::little-float-size(32),
    m_suspensionPosition_fr::little-float-size(32),
    # m_suspensionVelocity
    m_suspensionVelocity_rl::little-float-size(32),
    m_suspensionVelocity_rr::little-float-size(32),
    m_suspensionVelocity_fl::little-float-size(32),
    m_suspensionVelocity_fr::little-float-size(32),
    # m_suspensionAcceleration
    m_suspensionAcceleration_rl::little-float-size(32),
    m_suspensionAcceleration_rr::little-float-size(32),
    m_suspensionAcceleration_fl::little-float-size(32),
    m_suspensionAcceleration_fr::little-float-size(32),
    # m_wheelSpeed
    m_wheelSpeed_rl::little-float-size(32),
    m_wheelSpeed_rr::little-float-size(32),
    m_wheelSpeed_fl::little-float-size(32),
    m_wheelSpeed_fr::little-float-size(32),
    # m_wheelSlip
    m_wheelSlip_rl::little-float-size(32),
    m_wheelSlip_rr::little-float-size(32),
    m_wheelSlip_fl::little-float-size(32),
    m_wheelSlip_fr::little-float-size(32),

    m_localVelocityX::little-float-size(32),
    m_localVelocityY::little-float-size(32),
    m_localVelocityZ::little-float-size(32),

    m_angularVelocityX::little-float-size(32),
    m_angularVelocityY::little-float-size(32),
    m_angularVelocityZ::little-float-size(32),

    m_angularAccelerationX::little-float-size(32),
    m_angularAccelerationY::little-float-size(32),
    m_angularAccelerationZ::little-float-size(32),

    m_frontWheelsAngle::little-float-size(32)
  >>) do
    with {:ok, car_motion_data} <- fetch_car_motion_data(m_carMotionData) do
      {:ok, %__MODULE__{
        m_header: ph0,
        m_carMotionData: car_motion_data,
        m_suspensionPosition: [
          m_suspensionPosition_rl,
          m_suspensionPosition_rr,
          m_suspensionPosition_fl,
          m_suspensionPosition_fr,
        ],
        m_suspensionVelocity: [
          m_suspensionVelocity_rl,
          m_suspensionVelocity_rr,
          m_suspensionVelocity_fl,
          m_suspensionVelocity_fr,
        ],
        m_suspensionAcceleration: [
          m_suspensionAcceleration_rl,
          m_suspensionAcceleration_rr,
          m_suspensionAcceleration_fl,
          m_suspensionAcceleration_fr,
        ],
        m_wheelSpeed: [
          m_wheelSpeed_rl,
          m_wheelSpeed_rr,
          m_wheelSpeed_fl,
          m_wheelSpeed_fr,
        ],
        m_wheelSlip: [
          m_wheelSlip_rl,
          m_wheelSlip_rr,
          m_wheelSlip_fl,
          m_wheelSlip_fr,
        ],
        m_localVelocityX: m_localVelocityX,
        m_localVelocityY: m_localVelocityY,
        m_localVelocityZ: m_localVelocityZ,
        m_angularVelocityX: m_angularVelocityX,
        m_angularVelocityY: m_angularVelocityY,
        m_angularVelocityZ: m_angularVelocityZ,
        m_angularAccelerationX: m_angularAccelerationX,
        m_angularAccelerationY: m_angularAccelerationY,
        m_angularAccelerationZ: m_angularAccelerationZ,
        m_frontWheelsAngle: m_frontWheelsAngle,
      }}
    end
  end
  def from_binary(%F122PacketHeader{} = _ph0, _data) do
    {:error, %{packet_motion: ["is invalid"]}}
  end

  @doc false
  def fetch_car_motion_data(<<m_carMotionData::binary-size(1320)>>) do
    car_motion_data_items =
      split_car_motion_data(m_carMotionData, [])
      |> Enum.with_index()

    with {:ok, car_motion_items} <- parse_car_motion_items(car_motion_data_items, []),
      do: {:ok, car_motion_items}
  end

  @doc false
  def split_car_motion_data(<<item::binary-size(60)>>, accum) do
    Enum.reverse([item|accum])
  end
  def split_car_motion_data(<<item::binary-size(60), rest::binary>>, accum) do
    split_car_motion_data(rest, [item|accum])
  end

  @doc false
  def parse_car_motion_items([], accum), do: {:ok, Enum.reverse(accum)}
  def parse_car_motion_items([{<<item::binary-size(60)>>, index}|items], accum) do
    case F122PacketMotionCarMotion.from_binary(index, item) do
      {:ok, result} -> parse_car_motion_items(items, [result|accum])
      {:error, reason} -> {:error, reason}
    end
  end

end

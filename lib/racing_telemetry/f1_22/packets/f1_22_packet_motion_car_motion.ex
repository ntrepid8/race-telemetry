defmodule RacingTelemetry.F122.Packets.F122PacketMotionCarMotion do
  @moduledoc """
  Motion information about individual cars on the track.

  """
  require Logger

  defstruct [
    # original
    m_worldPositionX: nil,      # float - World space X position
    m_worldPositionY: nil,      # float - World space Y position
    m_worldPositionZ: nil,      # float - World space Z position
    m_worldVelocityX: nil,      # float - Velocity in world space X
    m_worldVelocityY: nil,      # float - Velocity in world space Y
    m_worldVelocityZ: nil,      # float - Velocity in world space Z
    m_worldForwardDirX: nil,    # int16 - World space forward X direction (normalised)
    m_worldForwardDirY: nil,    # int16 - World space forward Y direction (normalised)
    m_worldForwardDirZ: nil,    # int16 - World space forward Z direction (normalised)
    m_worldRightDirX: nil,      # int16 - World space right X direction (normalised)
    m_worldRightDirY: nil,      # int16 - World space right Y direction (normalised)
    m_worldRightDirZ: nil,      # int16 - World space right Z direction (normalised)
    m_gForceLateral: nil,       # float - Lateral G-Force component
    m_gForceLongitudinal: nil,  # float - Longitudinal G-Force component
    m_gForceVertical: nil,      # float - Vertical G-Force component
    m_yaw: nil,                 # float - Yaw angle in radians
    m_pitch: nil,               # float - Pitch angle in radians
    m_roll: nil,                # float - Roll angle in radians

    # extra
    car_index: nil,
  ]

  def from_binary(car_index, <<
    m_worldPositionX::little-float-size(32),
    m_worldPositionY::little-float-size(32),
    m_worldPositionZ::little-float-size(32),
    m_worldVelocityX::little-float-size(32),
    m_worldVelocityY::little-float-size(32),
    m_worldVelocityZ::little-float-size(32),
    m_worldForwardDirX::unsigned-little-integer-size(16),
    m_worldForwardDirY::unsigned-little-integer-size(16),
    m_worldForwardDirZ::unsigned-little-integer-size(16),
    m_worldRightDirX::unsigned-little-integer-size(16),
    m_worldRightDirY::unsigned-little-integer-size(16),
    m_worldRightDirZ::unsigned-little-integer-size(16),
    m_gForceLateral::little-float-size(32),
    m_gForceLongitudinal::little-float-size(32),
    m_gForceVertical::little-float-size(32),
    m_yaw::little-float-size(32),
    m_pitch::little-float-size(32),
    m_roll::little-float-size(32)>>
  ) do
    {:ok, %__MODULE__{
      # original
      m_worldPositionX: m_worldPositionX,
      m_worldPositionY: m_worldPositionY,
      m_worldPositionZ: m_worldPositionZ,
      m_worldVelocityX: m_worldVelocityX,
      m_worldVelocityY: m_worldVelocityY,
      m_worldVelocityZ: m_worldVelocityZ,
      m_worldForwardDirX: m_worldForwardDirX,
      m_worldForwardDirY: m_worldForwardDirY,
      m_worldForwardDirZ: m_worldForwardDirZ,
      m_worldRightDirX: m_worldRightDirX,
      m_worldRightDirY: m_worldRightDirY,
      m_worldRightDirZ: m_worldRightDirZ,
      m_gForceLateral: m_gForceLateral,
      m_gForceLongitudinal: m_gForceLongitudinal,
      m_gForceVertical: m_gForceVertical,
      m_yaw: m_yaw,
      m_pitch: m_pitch,
      m_roll: m_roll,

      # computed
      car_index: car_index,
    }}
  end
  def from_binary(car_index, data) do
    Logger.error("car_index=#{car_index} data_byte_size=#{byte_size(data)} data=#{inspect data}")
    {:error, %{packet_motion_car_motion: ["is invalid"]}}
  end

end

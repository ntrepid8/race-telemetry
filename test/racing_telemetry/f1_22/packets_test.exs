defmodule RacingTelemetry.F122.PacketsTest do
  use RacingTelemetry.DataCase
  require Logger
  alias RacingTelemetry, as: RT
  alias RacingTelemetry.F122.Packets.{
    F122PacketHeader,
    F122PacketEventData,
    F122PacketEventDetailButtonStatus,
    F122PacketMotionData,
    F122PacketMotionCarMotion,
    F122PacketLapData,
    F122PacketLapDataCarLapData,
    F122PacketCarTelemetry,
    F122PacketCarTelemetryCar,
  }


  describe "F1 22 - telemetry packets |" do

    test "car_damage" do
      data = read_fixture!("racing-telemetry-packet-sample.car_damage.dat")
      assert byte_size(data) == 948
    end

    test "car_setups" do
      data = read_fixture!("racing-telemetry-packet-sample.car_setups.dat")
      assert byte_size(data) == 1102
    end

    test "car_telemetry" do
      data = read_fixture!("racing-telemetry-packet-sample.car_telemetry.dat")
      assert byte_size(data) == 1347

      assert {:ok, %F122PacketCarTelemetry{} = packet} = RT.F122.Packets.from_binary(data)
      Logger.warn("packet=#{inspect packet, pretty: true}")
      assert %F122PacketCarTelemetry{
        m_header: %F122PacketHeader{
          m_packetFormat: 2022,
          m_gameMajorVersion: 1,
          m_gameMinorVersion: 6,
          m_packetVersion: 1,
          m_packetId: 6,
          m_sessionUID: 15722004913203710600,
          m_frameIdentifier: 0,
          m_playerCarIndex: 21,
          m_secondaryPlayerCarIndex: 255,
        },

        m_carTelemetryData: m_carTelemetryData,
        m_mfdPanelIndex: 255,
        m_mfdPanelIndexSecondaryPlayer: 255,
        m_suggestedGear: 0,
        mfd_panel: "Closed",
        mfd_panel_secondary_player: "Closed",
      } = packet

      assert length(m_carTelemetryData) == 22
      assert %F122PacketCarTelemetryCar{
        m_brake: 0.0,
        m_brakesTemperature: [33, 33, 33, 33],
        m_clutch: 0,
        m_drs: 0,
        m_engineRPM: 3429,
        m_engineTemperature: 110,
        m_gear: 0,
        m_revLightsBitValue: 0,
        m_revLightsPercent: 0,
        m_speed: 0,
        m_steer: -0.0,
        m_surfaceType: [0, 0, 0, 0],
        m_throttle: 0.0,
        m_tyresInnerTemperature: [70, 70, 70, 70],
        m_tyresPressure: [22.75, 22.75, 23.75, 23.75],
        m_tyresSurfaceTemperature: [70, 70, 70, 70],

        # computed
        car_index: 21,
        surface_type: ["Tarmac", "Tarmac", "Tarmac", "Tarmac"],
      } = Enum.at(m_carTelemetryData, 21)
    end

    test "event - BUTN" do
      data = read_fixture!("racing-telemetry-packet-sample.event.dat")
      assert byte_size(data) == 40

      assert {:ok, %F122PacketEventData{} = packet} = RT.F122.Packets.from_binary(data)
      Logger.warn("packet=#{inspect packet, pretty: true}")
      assert %F122PacketEventData{
        m_header: %F122PacketHeader{
          m_packetFormat: 2022,
          m_gameMajorVersion: 1,
          m_gameMinorVersion: 6,
          m_packetVersion: 1,
          m_packetId: 3,
          m_sessionUID: 15722004913203710600,
          m_frameIdentifier: 0,
          m_playerCarIndex: 21,
          m_secondaryPlayerCarIndex: 255,
        },

        m_eventStringCode: "BUTN",
        m_eventDetails: %F122PacketEventDetailButtonStatus{
          m_buttonStatus: 0,
          button_flags: [],
        },

        event_type: "button_status",
        event_name: "Button Status",
      } = packet
    end

    test "lap_data" do
      data = read_fixture!("racing-telemetry-packet-sample.lap_data.dat")
      assert byte_size(data) == 972

      assert {:ok, %F122PacketLapData{} = packet} = RT.F122.Packets.from_binary(data)
      Logger.warn("packet=#{inspect packet, pretty: true}")
      assert %F122PacketLapData{
        m_header: %F122PacketHeader{
          m_packetFormat: 2022,
          m_gameMajorVersion: 1,
          m_gameMinorVersion: 6,
          m_packetVersion: 1,
          m_packetId: 2,
          m_sessionUID: 15722004913203710600,
          m_frameIdentifier: 0,
          m_playerCarIndex: 21,
          m_secondaryPlayerCarIndex: 255,
        },
        m_lapData: m_lapData,
        m_timeTrialPBCarIdx: 255,
        m_timeTrialRivalCarIdx: 255,
      } = packet

      assert length(m_lapData) == 22
      assert %F122PacketLapDataCarLapData{
        car_index: 21,
        current_lap_invalid: "valid",
        driver_status: "in garage",
        m_carPosition: 15,
        m_currentLapInvalid: 0,
        m_currentLapNum: 1,
        m_currentLapTimeInMS: 0,
        m_driverStatus: 0,
        m_gridPosition: 1,
        m_lapDistance: 208.49658203125,
        m_lastLapTimeInMS: 0,
        m_numPitStops: 0,
        m_numUnservedDriveThroughPens: 0,
        m_numUnservedStopGoPens: 0,
        m_penalties: 0,
        m_pitLaneTimeInLaneInMS: 0,
        m_pitLaneTimerActive: 0,
        m_pitStatus: 1,
        m_pitStopShouldServePen: 0,
        m_pitStopTimerInMS: 0,
        m_resultStatus: 2,
        m_safetyCarDelta: -0.0,
        m_sector: 0,
        m_sector1TimeInMS: 0,
        m_sector2TimeInMS: 0,
        m_totalDistance: 208.49658203125,
        m_warnings: 0,
        pit_lane_timer_active: "inactive",
        pit_status: "pitting",
        result_status: "active",
        sector: 1
      } = Enum.at(m_lapData, 21)
    end

    test "motion" do
      data = read_fixture!("racing-telemetry-packet-sample.motion.dat")
      assert byte_size(data) == 1464

      assert {:ok, %F122PacketMotionData{} = packet} = RT.F122.Packets.from_binary(data)
      Logger.warn("packet=#{inspect packet, pretty: true}")
      %F122PacketMotionData{
        m_header: %F122PacketHeader{
          m_packetFormat: 2022,
          m_gameMajorVersion: 1,
          m_gameMinorVersion: 6,
          m_packetVersion: 1,
          m_packetId: 0,
          m_sessionUID: 15722004913203710600,
          m_frameIdentifier: 0,
          m_playerCarIndex: 21,
          m_secondaryPlayerCarIndex: 255,
        },
        m_carMotionData: m_carMotionData,
        m_suspensionPosition: [23.318056106567383, 23.318056106567383, 23.598445892333984, 23.598445892333984],
        m_suspensionVelocity: [0.0, 0.0, 0.0, 0.0],
        m_suspensionAcceleration: [0.0, 0.0, 0.0, 0.0],
        m_wheelSpeed: [0.0, 0.0, 0.0, 0.0],
        m_wheelSlip: [0.0, 0.0, 0.0, 0.0],
        m_localVelocityX: 0.0,
        m_localVelocityY: 0.0,
        m_localVelocityZ: 0.0,
        m_angularVelocityX: 0.0,
        m_angularVelocityY: 0.0,
        m_angularVelocityZ: 0.0,
        m_angularAccelerationX: 0.0,
        m_angularAccelerationY: 0.0,
        m_angularAccelerationZ: 0.0,
        m_frontWheelsAngle: -0.0,
      } = packet

      assert length(m_carMotionData) == 22
      assert %F122PacketMotionCarMotion{
        car_index: 21,
        m_gForceLateral: 0.0,
        m_gForceLongitudinal: 0.0,
        m_gForceVertical: 0.0,
        m_pitch: 8.538190741091967e-4,
        m_roll: -8.689098758623004e-4,
        m_worldForwardDirX: 65474,
        m_worldForwardDirY: 65279,
        m_worldForwardDirZ: 32765,
        m_worldPositionX: 263.4613952636719,
        m_worldPositionY: 39.8862419128418,
        m_worldPositionZ: -379.2652893066406,
        m_worldRightDirX: 32770,
        m_worldRightDirY: 28,
        m_worldRightDirZ: 65474,
        m_worldVelocityX: 0.0,
        m_worldVelocityY: 0.0,
        m_worldVelocityZ: 0.0,
        m_yaw: -0.0019201935501769185,
      } = Enum.at(m_carMotionData, 21)
    end

    test "participants" do
      data = read_fixture!("racing-telemetry-packet-sample.participants.dat")
      assert byte_size(data) == 1257
    end

    test "session" do
      data = read_fixture!("racing-telemetry-packet-sample.session.dat")
      assert byte_size(data) == 632
    end

    test "session_history" do
      data = read_fixture!("racing-telemetry-packet-sample.session_history.dat")
      assert byte_size(data) == 1155
    end

  end

end

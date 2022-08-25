defmodule RacingTelemetry.F122.Models.F122CarTelemetryPacketsTest do
  use RacingTelemetry.DataCase
  require Logger
  alias RacingTelemetry, as: RT
  alias RacingTelemetry.F122.Models.F122CarTelemetryPackets
  alias RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader
  alias RacingTelemetry.F122.Models.F122CarTelemetryPackets.{
    F122CarTelemetryPacket,
    F122CarTelemetryPacketCar,
  }

  describe "f1_22_car_telemetry_packets" do

    test "create_f1_22_car_telemetry_packet/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.car_telemetry.dat")
      assert {:ok, f1_22_packet_car_telemetry} = RT.F122.Packets.from_binary(data)

      assert {:ok, f1_22_car_telemetry_packet} =
        F122CarTelemetryPackets.create_f1_22_car_telemetry_packet(f1_22_packet_car_telemetry)
      assert %F122CarTelemetryPacket{
        object: "f1_22_car_telemetry_packet",
        id: f1_22_lap_data_packet_id,
        m_header: %F122PacketHeader{
          object: "f1_22_packet_header",
          id: _f1_22_packet_header_id,
          m_packetFormat: 2022,
          m_gameMajorVersion: 1,
          m_gameMinorVersion: 6,
          m_packetVersion: 1,
          m_packetId: 6,
          m_sessionUID: m_sessionUID,
          m_frameIdentifier: 0,
          m_playerCarIndex: 21,
          m_secondaryPlayerCarIndex: 255,
          packet_type: "car_telemetry",
        },
        m_carTelemetryData: m_carTelemetryData,
        m_mfdPanelIndex: 255,
        m_mfdPanelIndexSecondaryPlayer: 255,
        m_suggestedGear: 0,
        mfd_panel: "Closed",
        mfd_panel_secondary_player: "Closed",
      } = f1_22_car_telemetry_packet
      assert Decimal.to_integer(m_sessionUID) == 15722004913203710600
      assert Decimal.to_integer(f1_22_car_telemetry_packet.m_sessionUID) == 15722004913203710600
      assert is_list(m_carTelemetryData)
      assert length(m_carTelemetryData) == 22

      f1_22_car_telemetry_packet_car_21 = Enum.at(m_carTelemetryData, 21)
      assert %F122CarTelemetryPacketCar{
        f1_22_car_telemetry_packet_id: ^f1_22_lap_data_packet_id,
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
      } = f1_22_car_telemetry_packet_car_21
      assert Decimal.to_integer(f1_22_car_telemetry_packet_car_21.m_sessionUID) == 15722004913203710600
    end

    test "update_f1_22_car_telemetry_packet/2 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.car_telemetry.dat")
      assert {:ok, attrs} = RT.F122.Packets.from_binary(data)
      assert {:ok, f1_22_car_telemetry_packet} = F122CarTelemetryPackets.create_f1_22_car_telemetry_packet(attrs)

      assert {:ok, f1_22_car_telemetry_packet} =
        F122CarTelemetryPackets.update_f1_22_car_telemetry_packet(
          f1_22_car_telemetry_packet,
          %{m_suggestedGear: 1})
      assert %F122CarTelemetryPacket{
        m_suggestedGear: 1,
      } = f1_22_car_telemetry_packet
    end

    test "find_f1_22_car_telemetry_packets/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.car_telemetry.dat")
      assert {:ok, attrs} = RT.F122.Packets.from_binary(data)
      assert {:ok, f1_22_car_telemetry_packet} = F122CarTelemetryPackets.create_f1_22_car_telemetry_packet(attrs)

      opts = [preload_m_carTelemetryData: true, m_sessionUID: 15722004913203710600]
      assert F122CarTelemetryPackets.find_f1_22_car_telemetry_packets(opts) == [f1_22_car_telemetry_packet]
      opts = [preload_m_carTelemetryData: true, m_sessionUID: 12345]
      assert F122CarTelemetryPackets.find_f1_22_car_telemetry_packets(opts) == []
    end

  end

end

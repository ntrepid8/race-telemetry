defmodule RacingTelemetry.F122.Models.F122SessionPacketsTest do
  use RacingTelemetry.DataCase
  require Logger
  alias RacingTelemetry, as: RT
  alias RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader
  alias RacingTelemetry.F122.Models.F122SessionPackets
  alias RacingTelemetry.F122.Models.F122SessionPackets.{
    F122SessionPacket,
  }

  describe "f1_22_session_packets" do

    test "create_f1_22_session_packet/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.session.dat")
      assert {:ok, attrs} = RT.F122.Packets.from_binary(data)

      assert {:ok, f1_22_session_packet} = F122SessionPackets.create_f1_22_session_packet(attrs)
      assert %F122SessionPacket{
        m_header: %F122PacketHeader{
          m_packetFormat: 2022,
          m_gameMajorVersion: 1,
          m_gameMinorVersion: 6,
          m_packetVersion: 1,
          m_packetId: 1,
          m_sessionUID: m_sessionUID,
          m_frameIdentifier: 0,
          m_playerCarIndex: 21,
          m_secondaryPlayerCarIndex: 255,
        },
        m_DRSAssist: 1,
        m_ERSAssist: 1,
        m_aiDifficulty: 37,
        m_airTemperature: 22,
        m_brakingAssist: 0,
        m_dynamicRacingLine: 2,
        m_dynamicRacingLineType: 1,
        m_forecastAccuracy: 0,
        m_formula: 0,
        m_gameMode: 19,
        m_gamePaused: 0,
        m_gearboxAssist: 3,
        m_isSpectating: 0,
        m_marshalZones: m_marshalZones,
        m_networkGame: 0,
        m_numMarshalZones: 18,
        m_numWeatherForecastSamples: 38,
        m_pitAssist: 1,
        m_pitReleaseAssist: 1,
        m_pitSpeedLimit: 80,
        m_pitStopRejoinPosition: 0,
        m_pitStopWindowIdealLap: 0,
        m_pitStopWindowLatestLap: 0,
        m_ruleSet: 0,
        m_safetyCarStatus: 0,
        m_seasonLinkIdentifier: 2771600820,
        m_sessionDuration: 1800,
        m_sessionLength: 0,
        m_sessionLinkIdentifier: 2771601120,
        m_sessionTimeLeft: 1800,
        m_sessionType: 1,
        m_sliProNativeSupport: 0,
        m_spectatorCarIndex: 255,
        m_steeringAssist: 0,
        m_timeOfDay: 750,
        m_totalLaps: 1,
        m_trackId: 27,
        m_trackLength: 4910,
        m_trackTemperature: 29,
        m_weather: 2,
        m_weatherForecastSamples: m_weatherForecastSamples,
        m_weekendLinkIdentifier: 2771601120,
      } = f1_22_session_packet
      assert Decimal.to_integer(m_sessionUID) == 15722004913203710600
      assert length(m_marshalZones) == 18
      assert length(m_weatherForecastSamples) == 38
    end

    test "update_f1_22_session_packet/2 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.session.dat")
      assert {:ok, attrs} = RT.F122.Packets.from_binary(data)
      assert {:ok, f1_22_session_packet} = F122SessionPackets.create_f1_22_session_packet(attrs)

      assert {:ok, f1_22_session_packet} =
        F122SessionPackets.update_f1_22_session_packet(
          f1_22_session_packet,
          %{m_pitSpeedLimit: 81})

      assert %F122SessionPacket{
        m_pitSpeedLimit: 81,
      } = f1_22_session_packet
    end

    test "count_f1_22_session_packets/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.session.dat")
      assert {:ok, attrs} = RT.F122.Packets.from_binary(data)
      assert {:ok, _f1_22_session_packet} = F122SessionPackets.create_f1_22_session_packet(attrs)

      opts = [m_sessionUID: 15722004913203710600]
      assert F122SessionPackets.count_f1_22_session_packets(opts) == {:ok, 1}
      opts = [m_sessionUID: 15722004913203710601]
      assert F122SessionPackets.count_f1_22_session_packets(opts) == {:ok, 0}
    end

    test "find_f1_22_session_packets/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.session.dat")
      assert {:ok, attrs} = RT.F122.Packets.from_binary(data)
      assert {:ok, f1_22_session_packet} = F122SessionPackets.create_f1_22_session_packet(attrs)

      opts = [
        m_sessionUID: 15722004913203710600,
        preload_all: true,
      ]
      assert F122SessionPackets.find_f1_22_session_packets(opts) == [f1_22_session_packet]
      opts = [
        m_sessionUID: 15722004913203710601,
        preload_all: true,
      ]
      assert F122SessionPackets.find_f1_22_session_packets(opts) == []
    end

    test "fetch_one_f1_22_session_packet/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.session.dat")
      assert {:ok, attrs} = RT.F122.Packets.from_binary(data)
      assert {:ok, f1_22_session_packet} = F122SessionPackets.create_f1_22_session_packet(attrs)

      opts = [id: f1_22_session_packet.id, preload_all: true]
      assert {:ok, ^f1_22_session_packet} = F122SessionPackets.fetch_one_f1_22_session_packet(opts)
    end

    test "fetch_f1_22_session_packet/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.session.dat")
      assert {:ok, attrs} = RT.F122.Packets.from_binary(data)
      assert {:ok, f1_22_session_packet} = F122SessionPackets.create_f1_22_session_packet(attrs)

      assert {:ok, ^f1_22_session_packet} =
        F122SessionPackets.fetch_f1_22_session_packet(
          f1_22_session_packet.id,
          [preload_all: true])
    end

    test "delete_f1_22_session_packet/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.session.dat")
      assert {:ok, attrs} = RT.F122.Packets.from_binary(data)
      assert {:ok, %F122SessionPacket{id: f1_22_session_packet_id} = f1_22_session_packet} =
        F122SessionPackets.create_f1_22_session_packet(attrs)

      assert {:ok, %F122SessionPacket{id: ^f1_22_session_packet_id}} =
        F122SessionPackets.delete_f1_22_session_packet(f1_22_session_packet)

      assert {:error, %{f1_22_session_packet: ["not found"]}} =
        F122SessionPackets.fetch_f1_22_session_packet(
          f1_22_session_packet.id,
          [preload_all: true])
    end

  end

end

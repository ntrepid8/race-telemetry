defmodule RacingTelemetry.F122.Models.F122LapDataPacketsTest do
  use RacingTelemetry.DataCase
  require Logger
  alias RacingTelemetry, as: RT
  alias RacingTelemetry.F122.Models.F122LapDataPackets
  alias RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader
  alias RacingTelemetry.F122.Models.F122LapDataPackets.{
    F122LapDataPacket,
    F122LapDataPacketCar,
  }

  describe "f1_22_lap_data_packets" do

    test "create_f1_22_lap_data_packet/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.lap_data.dat")
      assert {:ok, f1_22_packet_lap_data} = RT.F122.Packets.from_binary(data)

      assert {:ok, f1_22_lap_data_packet} = F122LapDataPackets.create_f1_22_lap_data_packet(f1_22_packet_lap_data)
      assert %F122LapDataPacket{
        object: "f1_22_lap_data_packet",
        id: f1_22_lap_data_packet_id,
        m_header: %F122PacketHeader{
          object: "f1_22_packet_header",
          id: _f1_22_packet_header_id,
          m_packetFormat: 2022,
          m_gameMajorVersion: 1,
          m_gameMinorVersion: 6,
          m_packetVersion: 1,
          m_packetId: 2,
          m_sessionUID: m_sessionUID,
          m_frameIdentifier: 0,
          m_playerCarIndex: 21,
          m_secondaryPlayerCarIndex: 255,
          packet_type: "lap_data",
        },
        m_lapData: m_lapData,
        m_timeTrialPBCarIdx: 255,
        m_timeTrialRivalCarIdx: 255,
      } = f1_22_lap_data_packet
      assert Decimal.to_integer(m_sessionUID) == 15722004913203710600
      assert is_list(m_lapData)
      assert length(m_lapData) == 22
      Logger.warn("m_lapData[0]=#{inspect Enum.at(m_lapData, 0), pretty: true}")
      assert %F122LapDataPacketCar{
        object: "f1_22_lap_data_packet_car",
        m_lastLapTimeInMS: 0,
        car_index: 0,
        current_lap_invalid: "valid",
        deleted: false,
        driver_status: "in garage",
        f1_22_lap_data_packet_id: ^f1_22_lap_data_packet_id,
        inserted_at: %DateTime{},
        iteration: 1,
        live_mode: true,
        m_carPosition: 16,
        m_currentLapInvalid: 0,
        m_currentLapNum: 1,
        m_currentLapTimeInMS: 0,
        m_driverStatus: 0,
        m_gridPosition: 6,
        m_lapDistance: 42.35400390625,
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
        m_totalDistance: 42.35400390625,
        m_warnings: 0,
        pit_lane_timer_active: "inactive",
        pit_status: "pitting",
        result_status: "active",
        sector: 1,
        serial_number: _,
        updated_at: %DateTime{},
      } = Enum.at(m_lapData, 0)
    end

    test "create_f1_22_lap_data_packet_car/2 - success w/max m_lastLapTimeInMS" do
      data = read_fixture!("racing-telemetry-packet-sample.lap_data.dat")
      assert {:ok, f1_22_packet_lap_data} = RT.F122.Packets.from_binary(data)
      assert {:ok, f1_22_lap_data_packet} = F122LapDataPackets.create_f1_22_lap_data_packet(f1_22_packet_lap_data)

      max_val = :math.pow(2, 32) |> round()
      attrs =
        Enum.at(f1_22_packet_lap_data.m_lapData, 0)
        |> Map.put(:m_lastLapTimeInMS, max_val)
      assert {:ok, f1_22_lap_data_packet_car} =
        F122LapDataPackets.create_f1_22_lap_data_packet_car(f1_22_lap_data_packet, attrs)
      f1_22_lap_data_packet_car = RT.Repo.reload(f1_22_lap_data_packet_car)
      assert %F122LapDataPacketCar{
        m_lastLapTimeInMS: ^max_val,
      } = f1_22_lap_data_packet_car
    end

    test "create_f1_22_lap_data_packet_car/2 - success w/max m_lapDistance" do
      data = read_fixture!("racing-telemetry-packet-sample.lap_data.dat")
      assert {:ok, f1_22_packet_lap_data} = RT.F122.Packets.from_binary(data)
      assert {:ok, f1_22_lap_data_packet} = F122LapDataPackets.create_f1_22_lap_data_packet(f1_22_packet_lap_data)

      max_val = :math.pow(2, 31)
      attrs =
        Enum.at(f1_22_packet_lap_data.m_lapData, 0)
        |> Map.put(:m_lapDistance, max_val)
      assert {:ok, f1_22_lap_data_packet_car} =
        F122LapDataPackets.create_f1_22_lap_data_packet_car(f1_22_lap_data_packet, attrs)
      f1_22_lap_data_packet_car = RT.Repo.reload(f1_22_lap_data_packet_car)
      assert %F122LapDataPacketCar{
        m_lapDistance: ^max_val,
      } = f1_22_lap_data_packet_car
    end

    test "find_f1_22_lap_data_packets/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.lap_data.dat")
      assert {:ok, f1_22_packet_lap_data} = RT.F122.Packets.from_binary(data)
      assert {:ok, f1_22_lap_data_packet} = F122LapDataPackets.create_f1_22_lap_data_packet(f1_22_packet_lap_data)
      assert length(f1_22_lap_data_packet.m_lapData) == 22

      opts = [id: f1_22_lap_data_packet.id, preload_m_lapData: true]
      assert [item] = F122LapDataPackets.find_f1_22_lap_data_packets(opts)

      car_indexes = Enum.map(item.m_lapData, fn i -> i.car_index end) |> MapSet.new() |> MapSet.to_list() |> Enum.sort()
      Logger.warn("car_indexes=#{inspect car_indexes}")
      assert length(car_indexes) == 22

      assert length(item.m_lapData) == 22
      assert %{car_index: 0} = Enum.min_by(item.m_lapData, fn i -> i.car_index end)
      assert %{car_index: 21} = Enum.max_by(item.m_lapData, fn i -> i.car_index end)


      opts = [preload_m_lapData: true, m_sessionUID: 15722004913203710600]
      assert F122LapDataPackets.find_f1_22_lap_data_packets(opts) == [f1_22_lap_data_packet]
      opts = [preload_m_lapData: true, m_sessionUID: 12345]
      assert F122LapDataPackets.find_f1_22_lap_data_packets(opts) == []
    end

  end

end

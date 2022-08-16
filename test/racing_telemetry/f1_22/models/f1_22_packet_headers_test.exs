defmodule RacingTelemetry.F122.Models.F122PacketHeadersTest do
  use RacingTelemetry.DataCase
  require Logger
  alias RacingTelemetry, as: RT
  alias RacingTelemetry.F122.Models.F122PacketHeaders
  alias RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader

  describe "f1_22_packet_headers" do

    test "create_f1_22_packet_header/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.event.dat")
      assert {:ok, f1_22_packet_event_data} = RT.F122.Packets.from_binary(data)

      assert {:ok, f1_22_packet_header} =
        F122PacketHeaders.create_f1_22_packet_header(f1_22_packet_event_data.m_header)

      assert %F122PacketHeader{
        object: "f1_22_packet_header",
        m_packetFormat: 2022,
        m_gameMajorVersion: 1,
        m_gameMinorVersion: 6,
        m_packetVersion: 1,
        m_packetId: 3,
        m_sessionUID: m_sessionUID,
        m_frameIdentifier: 0,
        m_playerCarIndex: 21,
        m_secondaryPlayerCarIndex: 255,
        packet_type: "event",
      } = f1_22_packet_header
      assert Decimal.to_integer(m_sessionUID) == 15722004913203710600

      data = Jason.encode!(f1_22_packet_header, pretty: true)
      assert %{
        "id" => _uuid,
        "inserted_at" => _inserted_at,
        "live_mode" => true,
        "m_frameIdentifier" => 0,
        "m_gameMajorVersion" => 1,
        "m_gameMinorVersion" => 6,
        "m_packetFormat" => 2022,
        "m_packetId" => 3,
        "m_packetVersion" => 1,
        "m_playerCarIndex" => 21,
        "m_secondaryPlayerCarIndex" => 255,
        "m_sessionTime" => 0.0,
        "m_sessionUID" => "15722004913203710600",
        "object" => "f1_22_packet_header",
        "packet_type" => "event",
        "updated_at" => _updated_at,
      } = Jason.decode!(data)
    end

    test "update_f1_22_packet_header/2 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.event.dat")
      assert {:ok, f1_22_packet_event_data} = RT.F122.Packets.from_binary(data)
      assert {:ok, f1_22_packet_header} =
        F122PacketHeaders.create_f1_22_packet_header(f1_22_packet_event_data.m_header)
      assert %F122PacketHeader{
        m_gameMinorVersion: 6,
      } = f1_22_packet_header

      assert {:ok, f1_22_packet_header} =
        F122PacketHeaders.update_f1_22_packet_header(f1_22_packet_header, %{m_gameMinorVersion: 7})
      assert %F122PacketHeader{
        m_gameMinorVersion: 7,
      } = f1_22_packet_header
    end

    test "find_f1_22_packet_headers/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.event.dat")
      assert {:ok, f1_22_packet_event_data} = RT.F122.Packets.from_binary(data)
      assert {:ok, f1_22_packet_header} =
        F122PacketHeaders.create_f1_22_packet_header(f1_22_packet_event_data.m_header)

      opts = [m_sessionUID: 15722004913203710600]
      assert F122PacketHeaders.find_f1_22_packet_headers(opts) == {:ok, [f1_22_packet_header]}
      opts = [m_sessionUID: Decimal.new("15722004913203710600")]
      assert F122PacketHeaders.find_f1_22_packet_headers(opts) == {:ok, [f1_22_packet_header]}
      opts = [m_sessionUID: 15722004913203710601]
      assert F122PacketHeaders.find_f1_22_packet_headers(opts) == {:ok, []}
    end

    test "count_f1_22_packet_headers/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.event.dat")
      assert {:ok, f1_22_packet_event_data} = RT.F122.Packets.from_binary(data)
      assert {:ok, _f1_22_packet_header} =
        F122PacketHeaders.create_f1_22_packet_header(f1_22_packet_event_data.m_header)

      opts = [m_sessionUID: 15722004913203710600]
      assert F122PacketHeaders.count_f1_22_packet_headers(opts) == {:ok, 1}
      opts = [m_sessionUID: Decimal.new("15722004913203710600")]
      assert F122PacketHeaders.count_f1_22_packet_headers(opts) == {:ok, 1}
      opts = [m_sessionUID: 15722004913203710601]
      assert F122PacketHeaders.count_f1_22_packet_headers(opts) == {:ok, 0}
    end

    test "fetch_one_f1_22_packet_header/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.event.dat")
      assert {:ok, f1_22_packet_event_data} = RT.F122.Packets.from_binary(data)
      assert {:ok, f1_22_packet_header} =
        F122PacketHeaders.create_f1_22_packet_header(f1_22_packet_event_data.m_header)

      assert {:ok, ^f1_22_packet_header} =
        F122PacketHeaders.fetch_one_f1_22_packet_header(id: f1_22_packet_header.id)
    end

    test "fetch_f1_22_packet_header/2 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.event.dat")
      assert {:ok, f1_22_packet_event_data} = RT.F122.Packets.from_binary(data)
      assert {:ok, f1_22_packet_header} =
        F122PacketHeaders.create_f1_22_packet_header(f1_22_packet_event_data.m_header)

      assert {:ok, ^f1_22_packet_header} =
        F122PacketHeaders.fetch_f1_22_packet_header(f1_22_packet_header.id)
    end

    test "delete_f1_22_packet_header/1 - success" do
      data = read_fixture!("racing-telemetry-packet-sample.event.dat")
      assert {:ok, f1_22_packet_event_data} = RT.F122.Packets.from_binary(data)
      assert {:ok, %F122PacketHeader{id: f1_22_packet_header_id} = f1_22_packet_header} =
        F122PacketHeaders.create_f1_22_packet_header(f1_22_packet_event_data.m_header)

      assert {:ok, %F122PacketHeader{id: ^f1_22_packet_header_id}} =
        F122PacketHeaders.delete_f1_22_packet_header(f1_22_packet_header)

      assert {:error, %{f1_22_packet_header: ["not found"]}} =
        F122PacketHeaders.fetch_f1_22_packet_header(f1_22_packet_header.id)
    end

  end

end

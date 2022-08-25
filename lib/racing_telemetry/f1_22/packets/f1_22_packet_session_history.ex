defmodule RacingTelemetry.F122.Packets.F122PacketSessionHistory do
  @moduledoc """
  This packet contains lap times and tyre usage for the session.

  This packet works slightly differently to other packets. To reduce CPU and bandwidth, each packet relates
  to a specific vehicle and is sent every 1/20 s, and the vehicle being sent is cycled through. Therefore in
  a 20 car race you should receive an update for each vehicle at least once per second.

  Note that at the end of the race, after the final classification packet has been sent, a final bulk update of
  all the session histories for the vehicles in that session will be sent.

  Frequency: 20 per second but cycling through cars
  Size: 1155 bytes
  Version: 1

  """
  require Logger
  alias RacingTelemetry.F122.Packets.{
    F122PacketHeader,
    F122PacketSessionHistoryLap,
    F122PacketSessionHistoryTyre,
    F122PacketSession,
  }

  defstruct [
    # original
    m_header: nil,                 # F122PacketHeader
    m_carIdx: nil,                 # uint8 - Index of the car this lap data relates to
    m_numLaps: nil,                # uint8 - Num laps in the data (including current partial lap)
    m_numTyreStints: nil,          # uint8 - Number of tyre stints in the data
    m_bestLapTimeLapNum: nil,      # uint8 - Lap the best lap time was achieved on
    m_bestSector1LapNum: nil,      # uint8 - Lap the best Sector 1 time was achieved on
    m_bestSector2LapNum: nil,      # uint8 - Lap the best Sector 2 time was achieved on
    m_bestSector3LapNum: nil,      # uint8 - Lap the best Sector 3 time was achieved on
    m_lapHistoryData: nil,         # F122PacketSessionHistoryLap[100] - 100 laps of data max - 1100 bytes
    m_tyreStintsHistoryData: nil,  # F122PacketSessionHistoryTyre[8] - 8 stints of data max - 24 bytes

    # extra from F122PacketSession (Used to decode tyre compound)
    m_formula: nil,
    formula: nil,

    # computed
    car_index: nil,

    # header fields (for indexing)
    m_sessionUID: nil,
    m_sessionTime: nil,
    m_frameIdentifier: nil,
  ]

  def from_binary(ph0, data, opts \\ [])
  def from_binary(%F122PacketHeader{packet_type: "session_history"} = ph0, <<
    m_carIdx::unsigned-little-integer-size(8),
    m_numLaps::unsigned-little-integer-size(8),
    m_numTyreStints::unsigned-little-integer-size(8),
    m_bestLapTimeLapNum::unsigned-little-integer-size(8),
    m_bestSector1LapNum::unsigned-little-integer-size(8),
    m_bestSector2LapNum::unsigned-little-integer-size(8),
    m_bestSector3LapNum::unsigned-little-integer-size(8),
    m_lapHistoryData::binary-size(1100),
    m_tyreStintsHistoryData::binary-size(24)
  >>, opts) do
    # options
    ps0 = Keyword.get(opts, :packet_session)

    # f1_22_packet_session sanity check
    if !is_nil(ps0) and ps0.m_sessionUID != ph0.m_sessionUID do
      raise "invalid f1_22_packet_session_history, m_sessionUIDs do not match"
    end

    # decode
    with {:ok, lap_history_data} <- parse_lap_history_data(m_lapHistoryData, m_numLaps, ph0),
      {:ok, tyre_stint_history_data} <- parse_tyre_stint_history_data(m_tyreStintsHistoryData, m_numTyreStints, ph0, ps0)
    do
      result = %__MODULE__{
        m_header: ph0,
        m_carIdx: m_carIdx,
        m_numLaps: m_numLaps,
        m_numTyreStints: m_numTyreStints,
        m_bestLapTimeLapNum: m_bestLapTimeLapNum,
        m_bestSector1LapNum: m_bestSector1LapNum,
        m_bestSector2LapNum: m_bestSector2LapNum,
        m_bestSector3LapNum: m_bestSector3LapNum,
        m_lapHistoryData: lap_history_data,
        m_tyreStintsHistoryData: tyre_stint_history_data,

        # computed
        car_index: m_carIdx,  # for continuity with other structures

        # header field (for indexing)
        m_sessionUID: ph0.m_sessionUID,
        m_sessionTime: ph0.m_sessionTime,
        m_frameIdentifier: ph0.m_frameIdentifier,
      }

      result =
        case ps0 do
          # session was provided
          %F122PacketSession{} ->
            %{result|
              m_formula: ps0.m_formula,
              formula: ps0.formula}

          # session NOT provided
          _not_found ->
            result
        end

      # done
      {:ok, result}
    end
  end
  def from_binary(%F122PacketHeader{packet_type: "session_history"} = ph0, data, _opts) do
    Logger.error(
      "m_sessionUID=#{ph0.m_sessionUID} " <>
      "m_frameIdentifier=#{ph0.m_frameIdentifier} " <>
      "data_byte_size=#{byte_size(data)} ")
    {:error, "invalid session_history packet"}
  end

  @doc false
  def parse_lap_history_data(m_lapHistoryData, m_numLaps, ph0) do
    with {:ok, items} <- split_lap_history_data(m_lapHistoryData, m_numLaps, ph0, []),
      do: {:ok, items}
  end

  @doc false
  def split_lap_history_data(_rest, 0, _ph0, accum), do: {:ok, Enum.reverse(accum)}
  def split_lap_history_data(<<data::binary-size(11), rest::binary>>, count, ph0, accum) do
    with {:ok, item} <- F122PacketSessionHistoryLap.from_binary(ph0, data),
      do: split_lap_history_data(rest, count-1, ph0, [item|accum])
  end

  @doc false
  def parse_tyre_stint_history_data(m_tyreStintsHistoryData, m_numTyreStints, ph0, ps0) do
    with {:ok, items} <- split_tyre_stint_history_data(m_tyreStintsHistoryData, m_numTyreStints, ph0, ps0, []),
      do: {:ok, items}
  end

  @doc false
  def split_tyre_stint_history_data(_rest, 0, _ph0, _ps0, accum), do: {:ok, Enum.reverse(accum)}
  def split_tyre_stint_history_data(<<data::binary-size(3), rest::binary>>, count, ph0, ps0, accum) do
    with {:ok, item} <- F122PacketSessionHistoryTyre.from_binary(ph0, ps0, data),
      do: split_tyre_stint_history_data(rest, count-1, ph0, ps0, [item|accum])
  end

end

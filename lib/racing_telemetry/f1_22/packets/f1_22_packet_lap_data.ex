defmodule RacingTelemetry.F122.Packets.F122PacketLapData do
  @moduledoc """
  The lap data packet gives details of all the cars in the session.

  Frequency: Rate as specified in menus
  Size: 972 bytes
  Version: 1

  """
  require Logger
  alias RacingTelemetry.F122.Packets.{
    F122PacketHeader,
    F122PacketLapDataCarLapData,
  }

  defstruct [
    # original
    m_header: nil,                # header
    m_lapData: nil,               # LapData[22] - Lap data for all cars on track
    m_timeTrialPBCarIdx: nil,     # uint8 - Index of Personal Best car in time trial (255 if invalid)
    m_timeTrialRivalCarIdx: nil,  # uint8 - Index of Rival car in time trial (255 if invalid)

    # computed

    # header fields (for indexing)
    m_sessionUID: nil,
    m_sessionTime: nil,
    m_frameIdentifier: nil,
  ]

  def from_binary(%F122PacketHeader{packet_type: "lap_data"} = ph0, <<
    m_lapData::binary-size(946),
    m_timeTrialPBCarIdx::unsigned-little-integer-size(8),
    m_timeTrialRivalCarIdx::unsigned-little-integer-size(8),
  >>) do
    with {:ok, car_lap_data} <- fetch_car_lap_data(ph0, m_lapData) do
      {:ok, %__MODULE__{
        m_header: ph0,
        m_lapData: car_lap_data,
        m_timeTrialPBCarIdx: m_timeTrialPBCarIdx,
        m_timeTrialRivalCarIdx: m_timeTrialRivalCarIdx,

        # header field (for indexing)
        m_sessionUID: ph0.m_sessionUID,
        m_sessionTime: ph0.m_sessionTime,
        m_frameIdentifier: ph0.m_frameIdentifier,
      }}
    end
  end

  @doc false
  def fetch_car_lap_data(ph0, <<m_lapData::binary-size(946)>>) do
    split_car_lap_data(m_lapData)
    |> Enum.with_index()
    |> parse_car_lap_data_items(ph0)
  end

  @doc false
  def split_car_lap_data(items), do: split_car_lap_data(items, [])
  def split_car_lap_data(<<item::binary-size(43)>>, accum), do: Enum.reverse([item|accum])
  def split_car_lap_data(<<item::binary-size(43), rest::binary>>, accum) do
    split_car_lap_data(rest, [item|accum])
  end

  @doc false
  def parse_car_lap_data_items(items, ph0), do: parse_car_lap_data_items(items, ph0, [])
  def parse_car_lap_data_items([], _ph0, accum), do: {:ok, Enum.reverse(accum)}
  def parse_car_lap_data_items([{<<item::binary-size(43)>>, index}|items], ph0, accum) do
    case F122PacketLapDataCarLapData.from_binary(ph0, index, item) do
      {:ok, result} -> parse_car_lap_data_items(items, ph0, [result|accum])
      {:error, reason} -> {:error, reason}
    end
  end

end

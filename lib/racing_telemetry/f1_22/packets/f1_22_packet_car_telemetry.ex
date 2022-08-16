defmodule RacingTelemetry.F122.Packets.F122PacketCarTelemetry do
  @moduledoc """
  This packet details telemetry for all the cars in the race. It details various values that would be recorded on the
  car such as speed, throttle application, DRS etc. Note that the rev light configurations are presented separately
  as well and will mimic real life driver preferences.

  Frequency: Rate as specified in menus
  Size: 1347 bytes
  Version: 1

  """
  require Logger
  alias RacingTelemetry.F122.Packets.{
    F122PacketHeader,
    F122PacketCarTelemetryCar,
  }

  defstruct [
    # original
    m_header: nil,                        # header
    m_carTelemetryData: nil,              # CarTelemetryData[22] - Data for all cars on track
    m_mfdPanelIndex: nil,                 # uint8 - Index of MFD panel open - 255 = MFD closed
                                          #         Single player, race –
                                          #           0 = Car setup, 1 = Pits 2 = Damage, 3 =  Engine, 4 = Temperatures
                                          #         May vary depending on game mode
    m_mfdPanelIndexSecondaryPlayer: nil,  # uint8 - See above
    m_suggestedGear: nil,                 # int8 - Suggested gear for the player (1-8), 0 if no gear suggested

    # computed
    mfd_panel: nil,
    mfd_panel_secondary_player: nil,
  ]

  @mfd_panel %{
    255 => "Closed",
    0 => "Car setup",
    1 => "Pits",
    2 => "Damage",
    3 => "Engine",
    4 => "Temperatures",
  }

  def from_binary(%F122PacketHeader{packet_type: "car_telemetry"} = ph0, <<
    m_carTelemetryData::binary-size(1320),
    m_mfdPanelIndex::unsigned-little-integer-size(8),
    m_mfdPanelIndexSecondaryPlayer::unsigned-little-integer-size(8),
    m_suggestedGear::little-integer-size(8)
  >>) do
    with {:ok, car_data} <- fetch_car_data(m_carTelemetryData) do
      {:ok, %__MODULE__{
        m_header: ph0,
        m_carTelemetryData: car_data,
        m_mfdPanelIndex: m_mfdPanelIndex,
        m_mfdPanelIndexSecondaryPlayer: m_mfdPanelIndexSecondaryPlayer,
        m_suggestedGear: m_suggestedGear,

        # computed
        mfd_panel: Map.get(@mfd_panel, m_mfdPanelIndex),
        mfd_panel_secondary_player: Map.get(@mfd_panel, m_mfdPanelIndexSecondaryPlayer),
      }}
    end
  end

  @doc false
  def fetch_car_data(<<m_carTelemetryData::binary-size(1320)>>) do
    split_car_data(m_carTelemetryData)
    |> Enum.with_index()
    |> parse_car_data_items()
  end

  @doc false
  def split_car_data(items), do: split_car_data(items, [])
  def split_car_data(<<item::binary-size(60)>>, accum), do: Enum.reverse([item|accum])
  def split_car_data(<<item::binary-size(60), rest::binary>>, accum) do
    split_car_data(rest, [item|accum])
  end

  @doc false
  def parse_car_data_items(items), do: parse_car_data_items(items, [])
  def parse_car_data_items([], accum), do: {:ok, Enum.reverse(accum)}
  def parse_car_data_items([{<<item::binary-size(60)>>, index}|items], accum) do
    case F122PacketCarTelemetryCar.from_binary(index, item) do
      {:ok, result} -> parse_car_data_items(items, [result|accum])
      {:error, reason} -> {:error, reason}
    end
  end

end

defmodule RacingTelemetry.F122.Packets.F122PacketEventDetailButtonStatus do
  @moduledoc """
  Button status changed
  """
  use Bitwise, skip_operators: true
  require Logger

  defstruct [
    # original
    m_buttonStatus: nil,  # uint32 - Bit flags specifying which buttons are being pressed currently

    # computed
    button_flags: nil,
  ]

  @button_flags %{
    1 => "Cross or A",
    2 => "Triangle or Y",
    4 => "Circle or B",
    8 => "Square or X",
    10 => "D-pad Left",
    20 => "D-pad Right",
    40 => "D-pad Up",
    80 => "D-pad Down",
    100 => "Options or Menu",
    200 => "L1 or LB",
    400 => "R1 or RB",
    800 => "L2 or LT",
    1000 => "R2 or RT",
    2000 => "Left Stick Click",
    4000 => "Right Stick Click",
    8000 => "Right Stick Left",
    10000 => "Right Stick Right",
    20000 => "Right Stick Up",
    40000 => "Right Stick Down",
    80000 => "Special",
    100000 => "UDP Action 1",
    200000 => "UDP Action 2",
    400000 => "UDP Action 3",
    800000 => "UDP Action 4",
    1000000 => "UDP Action 5",
    2000000 => "UDP Action 6",
    4000000 => "UDP Action 7",
    8000000 => "UDP Action 8",
    10000000 => "UDP Action 9",
    20000000 => "UDP Action 10",
    40000000 => "UDP Action 11",
    80000000 => "UDP Action 12",
  }

  def from_binary(<<m_buttonStatus::unsigned-little-integer-size(32), _rest::binary>>) do
    {:ok, %__MODULE__{
      # original
      m_buttonStatus: m_buttonStatus,

      # computed
      button_flags: get_button_flags(m_buttonStatus),
    }}
  end
  def from_binary(data) do
    Logger.error("data=#{inspect data}")
    {:error, %{packet_event_detail_button_status: ["is invalid"]}}
  end

  @doc false
  def get_button_flags(m_buttonStatus) do
    Map.to_list(@button_flags)
    |> Enum.reduce([], fn {key, val}, accum ->
      case band(m_buttonStatus, key) > 0 do
        true -> [val|accum]
        false -> accum
      end
    end)
    |> Enum.reverse()
  end

end

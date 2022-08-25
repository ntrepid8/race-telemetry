defmodule RacingTelemetry.F122.Packets.F122PacketSessionHistoryTyre do
  @moduledoc """
  F122PacketSessionHistoryTyre

  Size: 24 bits / 3 bytes

  """
  require Logger
  alias RacingTelemetry.F122.Packets.{
    F122PacketHeader,
    F122PacketSession,
  }

  # from CarStatusData (not actually specified on TyreStintHistoryData)
  # by m_formula ID and value
  @actual_tyre_compound_ids %{
    # F1 Modern
    0 => %{
      16 => "C5",
      17 => "C4",
      18 => "C3",
      19 => "C2",
      10 => "C1",
      7 => "inter",
      8 => "wet",
    },

    # F1 Classic
    1 => %{
      9 => "dry",
      10 => "wet",
    },

    # F2
    2 => %{
      11 => "super soft",
      12 => "soft",
      13 => "medium",
      14 => "hard",
      15 => "wet",
    },

    # F1 Generic
    3 => %{},

    # Beta
    4 => %{},

    # Supercars
    5 => %{},
  }
  @visual_tyre_compound_ids %{
    # F1 Modern
    0 => %{
      16 => "soft",
      17 => "medium",
      18 => "hard",
      7 => "inter",
      8 => "wet",
    },

    # F1 Classic
    1 => %{
      9 => "dry",
      10 => "wet",
    },

    # F2
    2 => %{
      15 => "wet",
      19 => "super soft",
      20 => "soft",
      21 => "medium",
      22 => "hard",
    },

    # F1 Generic
    3 => %{},

    # Beta
    4 => %{},

    # Supercars
    5 => %{},
  }

  defstruct [
    # original
    m_endLap: nil,              # uint8 - Lap the tyre usage ends on (255 of current tyre)
    m_tyreActualCompound: nil,  # uint8 - Actual tyres used by this driver
    m_tyreVisualCompound: nil,  # uint8 - Visual tyres used by this driver

    # extra from F122PacketSession (Used to decode tyre compound)
    m_formula: nil,
    formula: nil,

    # computed
    tyre_actual_compound: nil,
    tyre_visual_compound: nil,

    # header fields (for indexing)
    m_sessionUID: nil,
    m_sessionTime: nil,
    m_frameIdentifier: nil,
  ]

  def from_binary(%F122PacketHeader{packet_type: "session_history"} = ph0, ps0, <<
    m_endLap::unsigned-little-integer-size(8),
    m_tyreActualCompound::unsigned-little-integer-size(8),
    m_tyreVisualCompound::unsigned-little-integer-size(8),
  >>) do
    result = %__MODULE__{
      # original
      m_endLap: m_endLap,
      m_tyreActualCompound: m_tyreActualCompound,
      m_tyreVisualCompound: m_tyreVisualCompound,

      # header field (for indexing)
      m_sessionUID: ph0.m_sessionUID,
      m_sessionTime: ph0.m_sessionTime,
      m_frameIdentifier: ph0.m_frameIdentifier,
    }

    result =
      case ps0 do
        # session was provided, lookup tyre compounds
        %F122PacketSession{} ->
          %{result|
            # extra from F122PacketSession (Used to decode tyre compound if provided)
            m_formula: ps0.m_formula,
            formula: ps0.formula,
            tyre_actual_compound: get_tyre_actual_compound(m_tyreActualCompound, ps0.m_formula),
            tyre_visual_compound: get_tyre_visual_compound(m_tyreVisualCompound, ps0.m_formula)}

        # session not provided, nothing to do
        _not_found ->
          result
      end

    # done
    {:ok, result}
  end
  def from_binary(ph0, _ps0, data) do
    Logger.error(
      "m_sessionUID=#{ph0.m_sessionUID} " <>
      "m_frameIdentifier=#{ph0.m_frameIdentifier} " <>
      "data_byte_size=#{byte_size(data)} ")
    {:error, %{packet_session_history_tyre: ["is invalid"]}}
  end

  def get_tyre_actual_compound(m_tyreActualCompound, 0) do
    Map.get(@actual_tyre_compound_ids, 0) |> Map.get(m_tyreActualCompound, "unknown F1 Modern")
  end
  def get_tyre_actual_compound(m_tyreActualCompound, 1) do
    Map.get(@actual_tyre_compound_ids, 1) |> Map.get(m_tyreActualCompound, "unknown F1 Classic")
  end
  def get_tyre_actual_compound(m_tyreActualCompound, 2) do
    Map.get(@actual_tyre_compound_ids, 2) |> Map.get(m_tyreActualCompound, "unknown F2")
  end
  def get_tyre_actual_compound(_m_tyreActualCompound, m_formula) do
    case m_formula do
      3 -> "unknown F1 Generic"
      4 -> "unknown F1 Beta"
      5 -> "unknown F1 Supercars"
      _ -> "unknown formula"
    end
  end

  def get_tyre_visual_compound(m_tyreVisualCompound, 0) do
    Map.get(@visual_tyre_compound_ids, 0) |> Map.get(m_tyreVisualCompound, "unknown F1 Modern")
  end
  def get_tyre_visual_compound(m_tyreVisualCompound, 1) do
    Map.get(@visual_tyre_compound_ids, 1) |> Map.get(m_tyreVisualCompound, "unknown F1 Classic")
  end
  def get_tyre_visual_compound(m_tyreVisualCompound, 2) do
    Map.get(@visual_tyre_compound_ids, 2) |> Map.get(m_tyreVisualCompound, "unknown F2")
  end
  def get_tyre_visual_compound(_m_tyreVisualCompound, m_formula) do
    case m_formula do
      3 -> "unknown F1 Generic"
      4 -> "unknown F1 Beta"
      5 -> "unknown F1 Supercars"
      _ -> "unknown formula"
    end
  end

end

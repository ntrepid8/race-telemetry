defmodule RacingTelemetry.F122.Filter do
  @moduledoc """
  Filter functions for F1 22 model lists.

  """
  require Logger

  @doc """
  Filter out any flashback frames.

  Items should all be from the same session and should only be for a single car_index.

  Function returns frames in m_frameIdentifier ascending order. The associated m_sessionTime is only
  allowed to increase.

  """
  def filter_car_flashback(items) do
    # for each unique frame-identifier, use the oldest one
    items
    |> Enum.sort_by(fn i -> {i.m_header.m_frameIdentifier, i.m_header.m_sessionTime} end)
    |> Enum.reverse()
    |> Enum.dedup_by(fn i -> i.m_header.m_frameIdentifier end)
    |> filter_car_flashback_frames()
  end

  @doc false
  def filter_car_flashback_frames(items) do
    items =
      Enum.sort_by(items, fn i -> {i.m_header.m_frameIdentifier, i.m_header.m_sessionTime} end)
      |> Enum.reverse()

    item_0 = Enum.at(items, 0)
    filter_car_flashback_frames(items, item_0.m_header.m_sessionTime, [])
  end
  def filter_car_flashback_frames([], _m_sessionTime, accum) do
    accum
  end
  def filter_car_flashback_frames([item|items], m_sessionTime, accum) do
    case item.m_header.m_sessionTime <= m_sessionTime do
      # next item occurs prior to current session time: OK
      true -> filter_car_flashback_frames(items, item.m_header.m_sessionTime, [item|accum])

      # time shift detected: filter out flashback frame
      false -> filter_car_flashback_frames(items, m_sessionTime, accum)
    end
  end

end

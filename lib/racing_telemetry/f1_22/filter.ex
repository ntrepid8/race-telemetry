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
    |> sort_by_frame_time_reverse()
    |> Enum.dedup_by(fn i -> i.m_header.m_frameIdentifier end)
    |> filter_car_flashback_frames()
  end

  @doc false
  def filter_car_flashback_frames(items) do
    items = sort_by_frame_time_reverse(items)

    item_0 = Enum.at(items, 0)
    m_sessionTime = item_0.m_header.m_sessionTime
    inserted_at = item_0.inserted_at
    filter_car_flashback_frames(items, m_sessionTime, inserted_at, [])
  end
  def filter_car_flashback_frames([], _m_sessionTime, _inserted_at, accum) do
    accum
  end
  def filter_car_flashback_frames([item|items], m_sessionTime, inserted_at, accum) do
    conditions = [
      (item.m_header.m_sessionTime <= m_sessionTime),
      datetime_is_less_than_or_equal_to?(item.inserted_at, inserted_at),
    ]
    case Enum.all?(conditions) do
      # next item occurs prior to current session time: OK
      true -> filter_car_flashback_frames(items, item.m_header.m_sessionTime, item.inserted_at, [item|accum])

      # time shift detected: filter out flashback frame
      false -> filter_car_flashback_frames(items, m_sessionTime, inserted_at, accum)
    end
  end

  @doc false
  def sort_by_frame_time_reverse(items) do
    items
    |> Enum.sort_by(fn i ->
      {i.m_header.m_frameIdentifier, i.m_header.m_sessionTime, DateTime.to_unix(i.inserted_at), i.serial_number}
    end)
    |> Enum.reverse()
  end

  @doc false
  def datetime_is_less_than_or_equal_to?(dt_0, dt_1) do
    case DateTime.compare(dt_0, dt_1) do
      :lt -> true
      :eq -> true
      :gt -> false
    end
  end

end

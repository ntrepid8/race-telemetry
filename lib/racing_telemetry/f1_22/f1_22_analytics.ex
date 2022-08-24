defmodule RacingTelemetry.F122Analytics do
  @moduledoc """
  The F122Analytics context.

  """
  require Logger
  alias RacingTelemetry, as: RT
  alias RacingTelemetry.F122.Models.F122LapDataPackets
  alias RacingTelemetry.F122.Models.F122CarTelemetryPackets
  alias RacingTelemetry.F122.Models.F122SessionPackets

  @doc """
  Fetch lap_data for a given user/session/lap_number/car_index.

  """
  def fetch_f1_22_lap_data(m_sessionUID, car_index, lap_number) do
    with {:ok, %{first: ld_first, last: ld_last}} <-
        F122LapDataPackets.fetch_f1_22_lap_data_packet_car_lap_first_and_last(m_sessionUID, car_index, lap_number),
      {:ok, session} <- F122SessionPackets.fetch_one_f1_22_session_packet([m_sessionUID: m_sessionUID, limit: 1])
    do
      lap_data = F122LapDataPackets.find_f1_22_lap_data_packet_car_lap_records(m_sessionUID, car_index, lap_number)
      car_telemetry =
        F122CarTelemetryPackets.find_f1_22_car_telemetry_packet_car_frames(
          m_sessionUID,
          car_index,
          ld_first.m_header.m_frameIdentifier,
          ld_last.m_header.m_frameIdentifier)
      # done
      {:ok, %{
        lap_data_first: ld_first,
        lap_data_last: ld_last,
        lap_data: lap_data,
        car_telemetry: car_telemetry,
        session: session,
      }}
    end
  end

  @doc """
  Fetch data to plot car_telemetry for the given session/car/lap.

  """
  def fetch_car_telemetry_plot_data(m_sessionUID, car_index, lap_number) do
    with {:ok, data} <- fetch_f1_22_lap_data(m_sessionUID, car_index, lap_number) do
      # speed KPH
      speed_plot_data =
        Enum.map(data.lap_data, fn lap_data ->
          case find_by_m_frameIdentifier(data.car_telemetry, lap_data.m_header.m_frameIdentifier) do
            nil -> nil
            car_telemetry -> %{y: car_telemetry.m_speed, x: lap_data.m_lapDistance}
          end
        end)
        |> Enum.filter(fn item -> !is_nil(item) end)

      # gear
      gear_plot_data =
        Enum.map(data.lap_data, fn lap_data ->
          case find_by_m_frameIdentifier(data.car_telemetry, lap_data.m_header.m_frameIdentifier) do
            nil -> nil
            car_telemetry -> %{y: car_telemetry.m_gear, x: lap_data.m_lapDistance}
          end
        end)
        |> Enum.filter(fn item -> !is_nil(item) end)

      # steer
      steer_plot_data =
        Enum.map(data.lap_data, fn lap_data ->
          case find_by_m_frameIdentifier(data.car_telemetry, lap_data.m_header.m_frameIdentifier) do
            nil -> nil
            car_telemetry -> %{y: car_telemetry.m_steer, x: lap_data.m_lapDistance}
          end
        end)
        |> Enum.filter(fn item -> !is_nil(item) end)

      # throttle
      throttle_plot_data =
        Enum.map(data.lap_data, fn lap_data ->
          case find_by_m_frameIdentifier(data.car_telemetry, lap_data.m_header.m_frameIdentifier) do
            nil -> nil
            car_telemetry -> %{y: car_telemetry.m_throttle, x: lap_data.m_lapDistance}
          end
        end)
        |> Enum.filter(fn item -> !is_nil(item) end)

      # brake
      brake_plot_data =
        Enum.map(data.lap_data, fn lap_data ->
          case find_by_m_frameIdentifier(data.car_telemetry, lap_data.m_header.m_frameIdentifier) do
            nil -> nil
            car_telemetry -> %{y: car_telemetry.m_brake, x: lap_data.m_lapDistance}
          end
        end)
        |> Enum.filter(fn item -> !is_nil(item) end)

      # DRS
      drs_plot_data =
        Enum.map(data.lap_data, fn lap_data ->
          case find_by_m_frameIdentifier(data.car_telemetry, lap_data.m_header.m_frameIdentifier) do
            nil -> nil
            car_telemetry -> %{y: car_telemetry.m_drs, x: lap_data.m_lapDistance}
          end
        end)
        |> Enum.filter(fn item -> !is_nil(item) end)

      # done
      {:ok, %{
        m_sessionUID: m_sessionUID,
        car_index: car_index,
        lap_number: lap_number,
        session: data.session,
        speed: speed_plot_data,
        gear: gear_plot_data,
        steer: steer_plot_data,
        throttle: throttle_plot_data,
        brake: brake_plot_data,
        drs: drs_plot_data,
      }}
    end
  end

  defp find_by_m_frameIdentifier(items, m_frameIdentifier) do
    Enum.find(items, fn
      %{m_header: %{m_frameIdentifier: ^m_frameIdentifier}} -> true
      _not_found -> false
    end)
  end

end

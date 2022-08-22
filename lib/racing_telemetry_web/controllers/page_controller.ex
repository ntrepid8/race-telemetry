defmodule RacingTelemetryWeb.PageController do
  use RacingTelemetryWeb, :controller
  alias RacingTelemetry, as: RT

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show_lap_data(conn, _params) do
    m_sessionUID = 4319743169360394010
    car_index = 21
    lap_number = 4
    with {:ok, plot_data} <- RT.F122.fetch_car_telemetry_plot_data(m_sessionUID, car_index, lap_number) do
      # format plot_data
      data =
        %{
          speed: %{
            datasets: [
              %{
                label: "Car #{car_index}, Lap #{lap_number}",
                data: plot_data.speed,
                backgroundColor: 'rgb(255, 99, 132)',
                showLine: true,
              },
            ],
          },
          gear: %{
            datasets: [
              %{
                label: "Car #{car_index}, Lap #{lap_number}",
                data: plot_data.gear,
                backgroundColor: 'rgb(255, 99, 132)',
                showLine: true,
              },
            ],
          },
          steer: %{
            datasets: [
              %{
                label: "Car #{car_index}, Lap #{lap_number}",
                data: plot_data.steer,
                backgroundColor: 'rgb(255, 99, 132)',
                showLine: true,
              },
            ],
          },
          throttle: %{
            datasets: [
              %{
                label: "Car #{car_index}, Lap #{lap_number}",
                data: plot_data.throttle,
                backgroundColor: 'rgb(255, 99, 132)',
                showLine: true,
              },
            ],
          },
          brake: %{
            datasets: [
              %{
                label: "Car #{car_index}, Lap #{lap_number}",
                data: plot_data.brake,
                backgroundColor: 'rgb(255, 99, 132)',
                showLine: true,
              },
            ],
          },
          drs: %{
            datasets: [
              %{
                label: "Car #{car_index}, Lap #{lap_number}",
                data: plot_data.drs,
                backgroundColor: 'rgb(255, 99, 132)',
                showLine: true,
              },
            ],
          },
        }
      # render
      render(conn, "lap_data.html", data: data)
    end
  end

  def show_real_time(conn, _params) do
    render(conn, "real_time.html")
  end

end

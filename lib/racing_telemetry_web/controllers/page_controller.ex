defmodule RacingTelemetryWeb.PageController do
  use RacingTelemetryWeb, :controller
  alias RacingTelemetry, as: RT

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def index_sessions(conn, _params) do
    data = %{
      sessions: RT.F122.find_f1_22_sessions(),
    }
    render(conn, "sessions.html", data: data)
  end

  def show_lap_data(conn, %{"m_sessionUID" => m_sessionUID, "car_index" => car_index, "lap_number" => lap_number}) do
    # m_sessionUID = 4319743169360394010
    # car_index = 21
    # lap_number = 4

    m_sessionUID = String.to_integer(m_sessionUID)
    car_index = String.to_integer(car_index)
    lap_number = String.to_integer(lap_number)
    with {:ok, plot_data} <- RT.F122.fetch_car_telemetry_plot_data(m_sessionUID, car_index, lap_number) do
      # format plot_data
      data =
        %{
          m_sessionUID: m_sessionUID,
          car_index: car_index,
          lap_number: lap_number,
          # plot datasets
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

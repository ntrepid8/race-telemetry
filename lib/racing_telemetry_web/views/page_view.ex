defmodule RacingTelemetryWeb.PageView do
  use RacingTelemetryWeb, :view
  alias RacingTelemetry, as: RT

  # def fetch_f1_22_lap_speed_plot_data(m_sessionUID, car_index, lap_number) do
  #   # m_sessionUID = 4319743169360394010
  #   # car_index = 21
  #   # lap_number = 1
  #   # label = "Car 21, Lap 1"
  #   # {:ok, plot_data} = RT.F122.fetch_plot_data_car_speed(4319743169360394010, 21, 2)
  #   # %{
  #   #   datasets: [
  #   #     # speed
  #   #     %{
  #   #       label: label,
  #   #       data: plot_data,
  #   #       backgroundColor: 'rgb(255, 99, 132)',
  #   #       showLine: true,
  #   #     },
  #   #   ],
  #   # }

  #   {:ok, plot_data} = RT.F122.fetch_plot_data_car_speed(m_sessionUID, car_index, lap_number)
  #   %{
  #     speed: %{
  #       datasets: [
  #         %{
  #           label: label,
  #           data: plot_data.speed,
  #           backgroundColor: 'rgb(255, 99, 132)',
  #           showLine: true,
  #         },
  #       ],
  #     }
  #   }
  # end

  def fetch_f1_22_lap_gear_plot_data(m_sessionUID, car_index, lap_number) do
  end

end

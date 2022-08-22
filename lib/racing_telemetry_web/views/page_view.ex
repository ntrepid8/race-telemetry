defmodule RacingTelemetryWeb.PageView do
  use RacingTelemetryWeb, :view

  def fetch_chart_data() do
    m_sessionUID = 4319743169360394010
    car_index = 21
    lap_number = 1
    %{
      datasets: [
        %{
          label: "Scatter Dataset",
          data: [
            %{x: -10, y: 0},
            %{x: 0, y: 10},
            %{x: 10, y: 5},
            %{x: 0.5, y: 5.5},
          ],
          backgroundColor: 'rgb(255, 99, 132)'
        },
      ],
    }
  end

end

defmodule RacingTelemetryWeb.PageController do
  use RacingTelemetryWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show_lap_data(conn, _params) do
    render(conn, "lap_data.html")
  end

  def show_real_time(conn, _params) do
    render(conn, "real_time.html")
  end

end

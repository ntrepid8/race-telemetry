defmodule RacingTelemetryWeb.PageControllerTest do
  use RacingTelemetryWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Racing Telemetry"
  end
end

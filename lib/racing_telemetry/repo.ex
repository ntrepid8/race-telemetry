defmodule RacingTelemetry.Repo do
  use Ecto.Repo,
    otp_app: :racing_telemetry,
    adapter: Ecto.Adapters.Postgres
end

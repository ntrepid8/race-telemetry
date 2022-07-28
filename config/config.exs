# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :racing_telemetry,
  ecto_repos: [RacingTelemetry.Repo]

# Configures the endpoint
config :racing_telemetry, RacingTelemetryWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TRsATr8w5Wm/DcDIHLKwVIendmInHWxstCJREBmFmxcCt2xcek7vfA0i8S+FUVnB",
  render_errors: [view: RacingTelemetryWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: RacingTelemetry.PubSub,
  live_view: [signing_salt: "xWEkKrC/"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

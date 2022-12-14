defmodule RacingTelemetry.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      RacingTelemetry.Repo,
      # Start the Telemetry supervisor
      RacingTelemetryWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: RacingTelemetry.PubSub},
      # Task supervisor
      {Task.Supervisor, name: RacingTelemetry.TaskSupervisor},
      # Start the Endpoint (http/https)
      RacingTelemetryWeb.Endpoint,
      # Start a worker by calling: RacingTelemetry.Worker.start_link(arg)
      # {RacingTelemetry.Worker, arg}

      # F1 22
      {RacingTelemetry.F122Supervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: RacingTelemetry.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    RacingTelemetryWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end

defmodule RacingTelemetry do
  @moduledoc """
  RacingTelemetry keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """
  require Logger

  @doc """
  Listen for telemetry.

  """
  def listen(:f1_22, opts \\ []) do
    RacingTelemetry.F122.listen(opts)
  end

end

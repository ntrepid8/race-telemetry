defmodule RacingTelemetry.DataFixtures do
  require Logger

  @doc """
  Load a fixture file.

  ## Example

    iex> read_fixture!("racing-telemetry-packet-sample.event.dat")

  """
  def read_fixture!(file_name) do
    Path.join([__DIR__, "fixtures/#{file_name}"])
    |> File.read!()
  end

  # Helpers

  # load JSON fixtures from the path relative to this file
  defp load_json_fixture_from_file(relative_path) do
    Path.join([__DIR__, relative_path])
    |> File.read!()
    |> Jason.decode!()
  end

end

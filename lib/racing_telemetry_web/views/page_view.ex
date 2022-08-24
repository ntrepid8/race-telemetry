defmodule RacingTelemetryWeb.PageView do
  use RacingTelemetryWeb, :view
  alias RacingTelemetry, as: RT


  @f1_22_circuit_maps %{
    3 => "/images/f1_22_circuit_maps/f1_22_bahrain.svg",
    30 => "/images/f1_22_circuit_maps/f1_22_miami.svg",
  }
  @f1_22_circuit_map_not_found "/images/f1_22_circuit_maps/circuit_map_not_found.svg"

  def get_f1_22_circuit_map_path(track_id) do
    Map.get(@f1_22_circuit_maps, track_id, @f1_22_circuit_map_not_found)
  end

end

defmodule RacingTelemetryWeb.PageView do
  use RacingTelemetryWeb, :view
  alias RacingTelemetry, as: RT


  @f1_22_circuit_maps %{
    0 => "/images/f1_22_circuit_maps/f1_22_melbourne.svg",
    1 => "/images/f1_22_circuit_maps/f1_22_paul_ricard.svg",
    2 => "/images/f1_22_circuit_maps/f1_22_shanghai.svg",
    3 => "/images/f1_22_circuit_maps/f1_22_bahrain.svg",
    4 => "/images/f1_22_circuit_maps/f1_22_catalunya.svg",
    5 => "/images/f1_22_circuit_maps/f1_22_monaco.svg",
    6 => "/images/f1_22_circuit_maps/f1_22_montreal.svg",
    7 => "/images/f1_22_circuit_maps/f1_22_silverstone.png",
    8 => "/images/f1_22_circuit_maps/f1_22_hockenheim.svg",
    9 => "/images/f1_22_circuit_maps/f1_22_hungaroring.svg",
    10 => "/images/f1_22_circuit_maps/f1_22_spa.svg",
    11 => "/images/f1_22_circuit_maps/f1_22_monza.svg",
    12 => "/images/f1_22_circuit_maps/f1_22_singapore.svg",
    13 => "/images/f1_22_circuit_maps/f1_22_suzuka.svg",
    14 => "/images/f1_22_circuit_maps/f1_22_abu_dhabi.png",
    15 => "/images/f1_22_circuit_maps/f1_22_texas.svg",
    20 => "/images/f1_22_circuit_maps/f1_22_baku.svg",
    30 => "/images/f1_22_circuit_maps/f1_22_miami.svg",
  }
  @f1_22_circuit_map_not_found "/images/f1_22_circuit_maps/circuit_map_not_found.svg"

  def get_f1_22_circuit_map_path(track_id) do
    Map.get(@f1_22_circuit_maps, track_id, @f1_22_circuit_map_not_found)
  end

end

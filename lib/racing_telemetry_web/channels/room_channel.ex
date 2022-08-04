defmodule RacingTelemetryWeb.RoomChannel do
  use Phoenix.Channel

  def join("room:lobby", _message, socket) do
    Phoenix.PubSub.subscribe(RacingTelemetry.PubSub, "player_car_motion_gForce")
    # RacingTelemetryWeb.Endpoint.subscribe("player_car_motion_gForce")
    {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info(%{topic: "player_car_motion_gForce", data: data}, socket) do
    push(socket, "player_car_motion_gForce", data)
    {:noreply, socket}
  end

end

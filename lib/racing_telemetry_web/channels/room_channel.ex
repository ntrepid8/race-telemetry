defmodule RacingTelemetryWeb.RoomChannel do
  use Phoenix.Channel

  @user_id 1
  @port 24134

  def join("room:lobby", _message, socket) do
    user_id = @user_id
    udp_listen_port = @port
    with {:ok, _} <- RacingTelemetry.F122.fetch_or_start_worker(user_id, listen_port: udp_listen_port),
      topic = "f1_22:/users/#{user_id}/player_car_motion_gForce",
      :ok <- Phoenix.PubSub.subscribe(RacingTelemetry.PubSub, topic),
      topic = "f1_22:/users/#{user_id}/udp_clients",
      :ok <- Phoenix.PubSub.subscribe(RacingTelemetry.PubSub, topic),
      Process.send(self(), {:push_udp_listen_port_update, [udp_listen_port]}, [:noconnect]),
      do: {:ok, socket}
  end

  def join("room:" <> _private_room_id, _params, _socket) do
    {:error, %{reason: "unauthorized"}}
  end

  def handle_info(%{key: {"f1_22", "users", _user_id, "player_car_motion_gForce"}, data: data}, socket) do
    push(socket, "player_car_motion_gForce", data)
    {:noreply, socket}
  end

  def handle_info(%{key: {"f1_22", "users", _user_id, "udp_clients"}, data: data}, socket) do
    push(socket, "udp_clients", data)
    {:noreply, socket}
  end

  def handle_info({:push_udp_listen_port_update, [udp_listen_port]}, socket) do
    push(socket, "udp_listen_port_update", %{udp_listen_port: udp_listen_port})
    {:noreply, socket}
  end

  # Helpers

end

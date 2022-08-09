// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import {Socket} from "phoenix"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:
socket.connect()

// Now that you are connected, you can join channels with a topic:
let channel = socket.channel("room:lobby", {})
let m_gForceLongitudinalForward = document.querySelector("#m_gForceLongitudinalForward")
let m_gForceLongitudinalAft = document.querySelector("#m_gForceLongitudinalAft")
let m_gForceLateralLeft = document.querySelector("#m_gForceLateralLeft")
let m_gForceLateralRight = document.querySelector("#m_gForceLateralRight")
let m_gForceVertical = document.querySelector("#m_gForceVertical")
let f1_22_udp_clients = document.querySelector("#f1_22_udp_clients")
let f1_22_udp_listen = document.querySelector("#f1_22_udp_listen")

// player_gForce_chart
const player_gForce_chart_data = {
  labels: [
    'Forward',
    'Right',
    'Aft',
    'Left',
  ],
  datasets: [{
    label: 'Player Car Long/Lat G-Forces',
    data: [0, 0, 0, 0],
    fill: true,
    backgroundColor: 'rgba(255, 99, 132, 0.2)',
    borderColor: 'rgb(255, 99, 132)',
    pointBackgroundColor: 'rgb(255, 99, 132)',
    pointBorderColor: '#fff',
    pointHoverBackgroundColor: '#fff',
    pointHoverBorderColor: 'rgb(255, 99, 132)'
  }]
};

const player_gForce_chart_config = {
  type: 'radar',
  data: player_gForce_chart_data,
  options: {
    elements: {
      line: {
        borderWidth: 1,
      }
    },
    scales: {
      r: {
        suggestedMin: 0,
        suggestedMax: 5,
      }
    }
  }
};

const player_gForce_chart_lat_long = new Chart(
  document.getElementById('player_gForce_chart_lat_long'),
  player_gForce_chart_config
);


// player_gForce_chart (vertical)
const player_gForce_vert_chart_data = {
  labels: [
    'Vertical',
  ],
  datasets: [{
    label: 'Player Car Vertical G-Forces',
    data: [0.0],
    backgroundColor: [
      'rgba(255, 99, 132, 0.2)',
    ],
    borderColor: [
      'rgb(255, 99, 132)',
    ],
    borderWidth: 1
  }]
};

const player_gForce_vert_chart_config = {
  type: 'bar',
  data: player_gForce_vert_chart_data,
  options: {
    scales: {
      y: {
        // beginAtZero: true,
        suggestedMin: -1.5,
        suggestedMax: 1.5,
      }
    }
  },
};


const player_gForce_chart_vert = new Chart(
  document.getElementById('player_gForce_chart_vert'),
  player_gForce_vert_chart_config
);

// motion charts update
channel.on("player_car_motion_gForce", payload => {
  // player car lat/long
  player_gForce_chart_lat_long.data.datasets[0].data = [
    payload.m_gForceLongitudinalForward,
    payload.m_gForceLateralRight,
    payload.m_gForceLongitudinalAft,
    payload.m_gForceLateralLeft,
  ];
  player_gForce_chart_lat_long.update();
  // player car vert
  player_gForce_chart_vert.data.datasets[0].data = [payload.m_gForceVertical];
  player_gForce_chart_vert.update();
})

// UDP clients update
channel.on("udp_clients", payload => {
  f1_22_udp_clients.textContent = payload.udp_clients.join(", ");
})

// UDP server listener update
channel.on("udp_listen_port_update", payload => {
  f1_22_udp_listen.textContent = `${window.location.hostname}:${payload.udp_listen_port}`;
})

channel.join()
  .receive("ok", resp => {
    console.log("Joined successfully", resp);
    player_gForce_chart_lat_long.update();
    player_gForce_chart_vert.update();
  })
  .receive("error", resp => {
    console.log("Unable to join", resp)
  })

export default socket

import socket from "./socket.js"

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
    // player_gForce_chart_lat_long.update();
    // player_gForce_chart_vert.update();
  })
  .receive("error", resp => {
    console.log("Unable to join", resp)
  })

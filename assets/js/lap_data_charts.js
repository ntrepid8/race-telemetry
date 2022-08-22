
let player_lap_data_chart_canvas = document.querySelector("#player_lap_data_chart");


const player_gForce_chart_vert = new Chart(
  player_lap_data_chart_canvas,
  {
    type: 'scatter',
    data: player_lap_data_chart_data,
    options: {
      scales: {
        x: {
          type: 'linear',
          position: 'bottom'
        }
      }
    }
  }
);

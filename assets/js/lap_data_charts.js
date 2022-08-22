
let f1_22_lap_speed_plot_canvas = document.querySelector("#f1_22_lap_speed_plot");
let f1_22_lap_gear_plot_canvas = document.querySelector("#f1_22_lap_gear_plot");
let f1_22_lap_steer_plot_canvas = document.querySelector("#f1_22_lap_steer_plot");
let f1_22_lap_throttle_plot_canvas = document.querySelector("#f1_22_lap_throttle_plot");
let f1_22_lap_brake_plot_canvas = document.querySelector("#f1_22_lap_brake_plot");
let f1_22_lap_drs_plot_canvas = document.querySelector("#f1_22_lap_drs_plot");


const f1_22_lap_speed_plot_chart = new Chart(
  f1_22_lap_speed_plot_canvas,
  {
    type: 'scatter',
    data: f1_22_lap_speed_plot_data,
    options: {
      maintainAspectRatio: false,
      scales: {
        x: {
          type: 'linear',
          position: 'bottom'
        }
      },
      plugins: {
        title: {
          display: true,
          text: 'Speed',
          position: 'left',
        }
      }
    }
  }
);

const f1_22_gear_plot_chart = new Chart(
  f1_22_lap_gear_plot_canvas,
  {
    type: 'scatter',
    data: f1_22_lap_gear_plot_data,
    options: {
      maintainAspectRatio: false,
      scales: {
        x: {
          type: 'linear',
          position: 'bottom'
        }
      },
      plugins: {
        title: {
          display: true,
          text: 'Gear',
          position: 'left',
        }
      }
    }
  }
);

const f1_22_steer_plot_chart = new Chart(
  f1_22_lap_steer_plot_canvas,
  {
    type: 'scatter',
    data: f1_22_lap_steer_plot_data,
    options: {
      maintainAspectRatio: false,
      scales: {
        x: {
          type: 'linear',
          position: 'bottom'
        }
      },
      plugins: {
        title: {
          display: true,
          text: 'Steer',
          position: 'left',
        }
      }
    }
  }
);

const f1_22_throttle_plot_chart = new Chart(
  f1_22_lap_throttle_plot_canvas,
  {
    type: 'scatter',
    data: f1_22_lap_throttle_plot_data,
    options: {
      maintainAspectRatio: false,
      scales: {
        x: {
          type: 'linear',
          position: 'bottom'
        }
      },
      plugins: {
        title: {
          display: true,
          text: 'Throttle',
          position: 'left',
        }
      }
    }
  }
);

const f1_22_brake_plot_chart = new Chart(
  f1_22_lap_brake_plot_canvas,
  {
    type: 'scatter',
    data: f1_22_lap_brake_plot_data,
    options: {
      maintainAspectRatio: false,
      scales: {
        x: {
          type: 'linear',
          position: 'bottom'
        }
      },
      plugins: {
        title: {
          display: true,
          text: 'Brake',
          position: 'left',
        }
      }
    }
  }
);

const f1_22_drs_plot_chart = new Chart(
  f1_22_lap_drs_plot_canvas,
  {
    type: 'scatter',
    data: f1_22_lap_drs_plot_data,
    options: {
      maintainAspectRatio: false,
      scales: {
        x: {
          type: 'linear',
          position: 'bottom'
        }
      },
      plugins: {
        title: {
          display: true,
          text: 'DRS',
          position: 'left',
        }
      }
    }
  }
);

defmodule RacingTelemetry.F122.Packets.F122PacketEventData do
  @moduledoc """
  This packet gives details of events that happen during the course of a session.

  """
  require Logger
  alias RacingTelemetry.F122.Packets.{
    F122PacketHeader,
    F122PacketEventDetailButtonStatus,
  }

  defstruct [
    # original
    m_header: nil,           # F122PacketHeader
    m_eventStringCode: nil,  # uint8
    m_eventDetails: nil,     # F122EventDataDetails

    # computed
    event_name: nil,  # human readable
    event_type: nil,  # snake-case key
  ]

  @event_types %{
    "SSTA" => "session_started",
    "SEND" => "session_ended",
    "FTLP" => "fastest_lap",
    "RTMP" => "retirement",
    "DRSE" => "drs_enabled",
    "DRSD" => "drs_disabled",
    "TMPT" => "team_mate_in_pits",
    "CHQF" => "chequered_flag",
    "RCWN" => "race_winner",
    "PENA" => "penalty_issued",
    "SPTP" => "speed_trap_triggered",
    "STLG" => "start_lights",
    "LGOT" => "oights_out",
    "DTSV" => "drive_through_served",
    "SGSV" => "stop_go_served",
    "FLBK" => "flashback",
    "BUTN" => "button_status",
  }

  @event_names %{
    "SSTA" => "Session Started",
    "SEND" => "Session Ended",
    "FTLP" => "Fastest Lap",
    "RTMP" => "Retirement",
    "DRSE" => "DRS Enabled",
    "DRSD" => "DRS Disabled",
    "TMPT" => "Team Mate in Pits",
    "CHQF" => "Chequered Flag",
    "RCWN" => "Race Winner",
    "PENA" => "Penalty Issued",
    "SPTP" => "Speed Trap Triggered",
    "STLG" => "Start Lights",
    "LGOT" => "Lights Out",
    "DTSV" => "Drive Through Served",
    "SGSV" => "Stop Go Served",
    "FLBK" => "Flashback",
    "BUTN" => "Button Status",
  }

  def from_binary(%F122PacketHeader{packet_type: "event"} = ph0, <<
    m_eventStringCode::binary-size(4),
    m_eventDetails::binary
  >>) do
    with {:ok, event_details} <- fetch_event_details(m_eventStringCode, m_eventDetails) do
      {:ok, %__MODULE__{
        m_header: ph0,
        m_eventStringCode: m_eventStringCode,
        m_eventDetails: event_details,

        event_name: Map.get(@event_names, m_eventStringCode, "invalid"),
        event_type: Map.get(@event_types, m_eventStringCode, "invalid"),
      }}
    end
  end
  def from_binary(%F122PacketHeader{} = _ph0, _data) do
    {:error, %{packet_event: ["is invalid"]}}
  end

  @doc false
  def fetch_event_details("BUTN", data), do: F122PacketEventDetailButtonStatus.from_binary(data)
  def fetch_event_details(m_eventStringCode, _data) do
    {:error, %{packet_event: ["m_eventStringCode is invalid, found #{inspect m_eventStringCode}"]}}
  end

end

defmodule RacingTelemetry.F122.Models.F122CarTelemetryPackets do
  @moduledoc """
  The F122CarTelemetryPackets context.

  """
  use RacingTelemetry.Query
  require Logger
  alias RacingTelemetry, as: RT
  alias RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader
  alias RacingTelemetry.F122.Models.F122CarTelemetryPackets.{
    F122CarTelemetryPacket,
    F122CarTelemetryPacketCar,
  }

  @f1_22_car_telemetry_packet_preloads [:m_header, :m_carTelemetryData]


  @doc """
  Creates a f1_22_car_telemetry_packet.

  ## Examples

      iex> create_f1_22_car_telemetry_packet(%{field: value})
      {:ok, %F122CarTelemetryPacket{}}

      iex> create_f1_22_car_telemetry_packet(%{field: bad_value})
      {:error, reason}

  """
  def create_f1_22_car_telemetry_packet(%{} = attrs) do
    # create
    %F122CarTelemetryPacket{}
    |> F122CarTelemetryPacket.changeset(attrs)
    |> RT.Repo.insert()
    |> case do
      {:ok, item} -> {:ok, preload_f1_22_car_telemetry_packet(item)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc false
  def preload_f1_22_car_telemetry_packet(%F122CarTelemetryPacket{} = ct0, opts \\ []) do
    RT.Repo.preload(ct0, @f1_22_car_telemetry_packet_preloads, opts)
  end

  @doc """
  Updates a f1_22_car_telemetry_packet.

  ## Examples

      iex> update_f1_22_car_telemetry_packet(f1_22_car_telemetry_packet, %{field: value})
      {:ok, %F122CarTelemetryPacket{}}

      iex> update_f1_22_car_telemetry_packet(f1_22_car_telemetry_packet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_f1_22_car_telemetry_packet(%F122CarTelemetryPacket{} = ct0, %{} = attrs) do
    # update
    F122CarTelemetryPacket.changeset(ct0, attrs)
    |> RT.Repo.update()
    |> case do
      {:ok, item} -> {:ok, preload_f1_22_car_telemetry_packet(item)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Like `find_f1_22_car_telemetry_packets/1` except returns a count of the items instead of a list.

  ## Examples

      iex> count_f1_22_car_telemetry_packets(key: val)
      {:ok, 1}

  """
  def count_f1_22_car_telemetry_packets(opts \\ []) do
    with {:ok, q} <- find_f1_22_car_telemetry_packets_query(opts) do
      [count] = Ecto.Query.select(q, [i], count(i.id)) |> RT.Repo.all()
      {:ok, count}
    end
  end

  @doc """
  Find f1_22_car_telemetry_packets according to query parameters in `opts`.

  ## Examples

      iex> find_f1_22_car_telemetry_packets(id: 123)
      [%F122CarTelemetryPacket{}, ...]

  """
  def find_f1_22_car_telemetry_packets(opts \\ []) do
    case fetch_f1_22_car_telemetry_packets(opts) do
      {:ok, items} -> items
      {:error, reason} -> raise "find_f1_22_car_telemetry_packets: reason=#{inspect reason}"
    end
  end

  @doc """
  Fetch f1_22_car_telemetry_packets according to query parameters in `opts`.

  ## Examples

      iex> fetch_f1_22_car_telemetry_packets(id: 123)
      {:ok, [%F122CarTelemetryPacket{}, ...]}

  """
  def fetch_f1_22_car_telemetry_packets(opts \\ []) do
    with {:ok, q} <- find_f1_22_car_telemetry_packets_query(opts),
      {:ok, q} <- RT.Query.find_query_extra(q, opts),
      q = find_f1_22_car_telemetry_packets_query_preload_m_carTelemetryData(q, opts),
      q = RT.Query.find_query_m_header_preload_defaults(q),
      q = RT.Query.find_query_m_header_order_by(q),
      do: {:ok, RT.Repo.all(q)}
  end

  @doc false
  def find_f1_22_car_telemetry_packets_query(opts \\ []) do
    q = Ecto.Query.from(n in F122CarTelemetryPacket)
    with {:ok, q} <- RT.Query.find_query_base(q, opts),
      {:ok, q} <- RT.Query.find_query_m_header_m_sessionUID(q, opts),
      do: {:ok, q}
  end

  @doc false
  def find_f1_22_car_telemetry_packets_query_preload_m_carTelemetryData(q, opts) do
    case Keyword.fetch(opts, :preload_m_carTelemetryData) do
      {:ok, true} -> Ecto.Query.preload(q, [:m_carTelemetryData])
      _false -> q
    end
  end

  def fetch_f1_22_car_telemetry_packet_sessions(opts \\ []) do
    with {:ok, q} <- find_f1_22_car_telemetry_packets_query(opts),
      {:ok, q} <- RT.Query.find_query_extra(q, opts),
      q = find_f1_22_car_telemetry_packets_query_preload_m_carTelemetryData(q, opts),
      q = RT.Query.find_query_m_header_preload_defaults(q),
      q = Ecto.Query.order_by(q, [{:asc, as(:m_header).inserted_at}]),
      q = Ecto.Query.distinct(q, as(:m_header).m_sessionUID)
    do
      items =
        RT.Repo.all(q)
        |> Enum.map(fn i -> i.m_header end)
        |> Enum.sort_by(fn i -> DateTime.to_unix(i.inserted_at) end)
      {:ok, items}
    end
  end

  @doc """
  Find a list of available sessions.

  """
  def find_f1_22_car_telemetry_packet_sessions() do
    # find the earliest record for each session
    sub_q =
      Ecto.Query.from(n in F122CarTelemetryPacket)
      |> RT.Query.ensure_join(:inner, :m_header)
      |> Ecto.Query.group_by(as(:m_header).m_sessionUID)
      |> Ecto.Query.select(%{
        inserted_at: min(as(:m_header).inserted_at),
        m_sessionUID: as(:m_header).m_sessionUID,
      })

    # sort by date, session
    Ecto.Query.from(i in subquery(sub_q), order_by: [asc: i.inserted_at, asc: i.m_sessionUID])
    |> RT.Repo.all()
  end

  @doc """
  Like `find_f1_22_car_telemetry_packet_cars/1` except returns a count of the items instead of a list.

  ## Examples

      iex> count_f1_22_car_telemetry_packet_cars(key: val)
      {:ok, 1}

  """
  def count_f1_22_car_telemetry_packet_cars(opts \\ []) do
    with {:ok, q} <- find_f1_22_car_telemetry_packet_cars_query(opts) do
      [count] = Ecto.Query.select(q, [i], count(i.id)) |> RT.Repo.all()
      {:ok, count}
    end
  end

  @doc """
  Find f1_22_car_telemetry_packet_cars according to query parameters in `opts`.

  ## Examples

      iex> find_f1_22_car_telemetry_packet_cars(id: 123)
      [%F122CarTelemetryPacket{}, ...]

  """
  def find_f1_22_car_telemetry_packet_cars(opts \\ []) do
    case fetch_f1_22_car_telemetry_packet_cars(opts) do
      {:ok, items} -> items
      {:error, reason} -> raise "find_f1_22_car_telemetry_packet_cars: reason=#{inspect reason}"
    end
  end

  @doc """
  Fetch f1_22_car_telemetry_packet_cars according to query parameters in `opts`.

  ## Examples

      iex> fetch_f1_22_car_telemetry_packet_cars(id: 123)
      {:ok, [%F122CarTelemetryPacketCar{}, ...]}

  """
  def fetch_f1_22_car_telemetry_packet_cars(opts \\ []) do
    with {:ok, q} <- find_f1_22_car_telemetry_packet_cars_query(opts),
      {:ok, q} <- RT.Query.find_query_extra(q, opts),
      q = RT.Query.find_query_m_header_preload_defaults(q),
      q = RT.Query.find_query_m_header_order_by(q),
      items = RT.Repo.all(q),
      items = maybe_dedup_f1_22_car_telemetry_packet_car_frames(items, opts),
      do: {:ok, items}
  end

  @doc false
  def find_f1_22_car_telemetry_packet_cars_query(opts \\ []) do
    q = Ecto.Query.from(n in F122CarTelemetryPacketCar)
    with {:ok, q} <- RT.Query.find_query_base(q, opts),
      {:ok, q} <- RT.Query.find_query_m_header_m_sessionUID(q, opts),
      {:ok, q} <- RT.Query.find_query_m_header_m_frameIdentifier(q, opts),
      {:ok, q} <- RT.Query.find_query_m_header_m_frameIdentifier_gte(q, opts),
      {:ok, q} <- RT.Query.find_query_m_header_m_frameIdentifier_lte(q, opts),
      {:ok, q} <- find_f1_22_car_telemetry_packet_cars_query_car_index(q, opts),
      do: {:ok, q}
  end

  @doc false
  def find_f1_22_car_telemetry_packet_cars_query_car_index(q, opts) do
    case Keyword.fetch(opts, :car_index) do
      {:ok, val} ->
        q = Ecto.Query.where(q, [i], i.car_index == ^val)
        {:ok, q}
      _not_found ->
        {:ok, q}
    end
  end

  @doc false
  def maybe_dedup_f1_22_car_telemetry_packet_car_frames(items, opts \\ []) do
    case Keyword.get(opts, :dedup_m_frameIdentifier) do
      true -> dedup_f1_22_car_telemetry_packet_car_frames(items)
      _false -> items
    end
  end

  @doc false
  def dedup_f1_22_car_telemetry_packet_car_frames(items) do
    Enum.dedup_by(items, fn i -> i.m_header.m_frameIdentifier end)
  end

  @doc """
  Write the list of items to the given file_path.

  """
  def write_f1_22_car_telemetry_packet_cars_csv(items, file_path) do
    # open the file
    file = File.open!(file_path, [:write, :utf8])

    # write the header
    [F122CarTelemetryPacketCar.get_csv_header()]
    |> CSV.encode()
    |> Enum.each(fn i -> IO.write(file, i) end)

    # wite the lines
    Enum.map(items, fn i -> F122CarTelemetryPacketCar.to_csv_row(i) end)
    |> CSV.encode()
    |> Enum.each(fn i -> IO.write(file, i) end)

    # close the file
    File.close(file)
  end

  @doc """
  Write a CSV for the given session and car_index.

  """
  def write_f1_22_car_telemetry_packet_car_csv(m_sessionUID, car_index, opts \\ []) do
    m_sessionUID = Decimal.new(m_sessionUID)
    default_path = "/tmp/RT-F122.car-telemetry.sessionUID-#{Decimal.to_string(m_sessionUID)}.car_index-#{car_index}.csv"
    file_path = Keyword.get(opts, :file_path) || default_path

    find_f1_22_car_telemetry_packet_cars(m_sessionUID: m_sessionUID, car_index: car_index)
    |> write_f1_22_car_telemetry_packet_cars_csv(file_path)
  end

  @doc """
  Find the f1_22_car_telemetry_packet_car records for the given frame range.

  This is used to pull car_telemetry for a given lap.

  """
  def find_f1_22_car_telemetry_packet_car_frames(m_sessionUID, car_index, first_frame, last_frame) do
    opts = [
      m_sessionUID: m_sessionUID,
      car_index: car_index,
      dedup_m_frameIdentifier: true,
      m_frameIdentifier_gte: first_frame,
      m_frameIdentifier_lte: last_frame,
      order_by: [{:m_frameIdentifier, :asc}, {:m_sessionTime, :desc}],
    ]
    find_f1_22_car_telemetry_packet_cars(opts)
    |> RT.F122.Filter.filter_car_flashback()
  end

end

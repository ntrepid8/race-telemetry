defmodule RacingTelemetry.F122.Models.F122LapDataPackets do
  @moduledoc """
  The F122LapDataPackets context.

  """
  use RacingTelemetry.Query
  require Logger
  alias RacingTelemetry, as: RT
  alias RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader
  alias RacingTelemetry.F122.Models.F122LapDataPackets.{
    F122LapDataPacket,
    F122LapDataPacketCar,
  }

  @f1_22_lap_data_packet_preloads [:m_lapData, :m_header]

  @doc """
  Creates a f1_22_lap_data_packet.

  ## Examples

      iex> create_f1_22_lap_data_packet(%{field: value})
      {:ok, %F122LapDataPacket{}}

      iex> create_f1_22_lap_data_packet(%{field: bad_value})
      {:error, reason}

  """
  def create_f1_22_lap_data_packet(%{} = attrs) do
    # create
    %F122LapDataPacket{}
    |> F122LapDataPacket.changeset(attrs)
    |> RT.Repo.insert()
    |> case do
      {:ok, item} -> {:ok, preload_f1_22_lap_data_packet(item)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc false
  def preload_f1_22_lap_data_packet(%F122LapDataPacket{} = ld0, opts \\ []) do
    RT.Repo.preload(ld0, @f1_22_lap_data_packet_preloads, opts)
  end

  @doc """
  Updates a f1_22_lap_data_packet.

  ## Examples

      iex> update_f1_22_lap_data_packet(f1_22_lap_data_packet, %{field: value})
      {:ok, %F122LapDataPacket{}}

      iex> update_f1_22_lap_data_packet(f1_22_lap_data_packet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_f1_22_lap_data_packet(%F122LapDataPacket{} = ld0, %{} = attrs) do
    # update
    F122LapDataPacket.changeset(ld0, attrs)
    |> RT.Repo.update()
    |> case do
      {:ok, item} -> {:ok, preload_f1_22_lap_data_packet(item)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Like `find_f1_22_lap_data_packets/1` except returns a count of the items instead of a list.

  ## Examples

      iex> count_f1_22_lap_data_packet(key: val)
      {:ok, 1}

  """
  def count_f1_22_lap_data_packets(opts \\ []) do
    with {:ok, q} <- find_f1_22_lap_data_packets_query(opts) do
      [count] = Ecto.Query.select(q, [i], count(i.id)) |> RT.Repo.all()
      {:ok, count}
    end
  end

  @doc """
  Find f1_22_lap_data_packet according to query parameters in `opts`.

  ## Examples

      iex> find_f1_22_lap_data_packets(id: 123)
      [%F122LapDataPacket{}, ...]

  """
  def find_f1_22_lap_data_packets(opts \\ []) do
    case fetch_f1_22_lap_data_packets(opts) do
      {:ok, items} -> items
      {:error, reason} -> raise "find_f1_22_lap_data_packets: reason=#{inspect reason}"
    end
  end

  @doc """
  Fetch f1_22_lap_data_packet according to query parameters in `opts`.

  ## Examples

      iex> find_f1_22_lap_data_packets(id: 123)
      {:ok, [%F122LapDataPacket{}, ...]}

  """
  def fetch_f1_22_lap_data_packets(opts \\ []) do
    with {:ok, q} <- find_f1_22_lap_data_packets_query(opts),
      {:ok, q} <- RT.Query.find_query_extra(q, opts),
      q = find_f1_22_lap_data_packets_query_preload_defaults(q),
      q = find_f1_22_lap_data_packets_query_preload_m_lapData(q, opts),
      q = find_f1_22_lap_data_packets_query_order_by(q),
      do: {:ok, RT.Repo.all(q)}
  end

  @doc false
  def find_f1_22_lap_data_packets_query(opts \\ []) do
    q = Ecto.Query.from(n in F122LapDataPacket)
    with {:ok, q} <- RT.Query.find_query_base(q, opts),
      {:ok, q} <- find_f1_22_lap_data_packets_query_m_sessionUID(q, opts),
      do: {:ok, q}
  end

  @doc false
  def find_f1_22_lap_data_packets_query_m_sessionUID(q, opts) do
    case Keyword.fetch(opts, :m_sessionUID) do
      {:ok, val} ->
        q =
          RT.Query.ensure_join(q, :inner, :m_header)
          |> Ecto.Query.where(as(:m_header).m_sessionUID == ^val)
        {:ok, q}
      _not_found ->
        {:ok, q}
    end
  end

  @doc false
  def find_f1_22_lap_data_packets_query_order_by(q) do
    q
    |> RT.Query.ensure_join(:inner, :m_header)
    |> Ecto.Query.order_by([{:asc, as(:m_header).m_sessionTime}, {:asc, as(:m_header).m_frameIdentifier}])
  end

  @doc false
  def find_f1_22_lap_data_packets_query_preload_defaults(q) do
    q
    |> RT.Query.ensure_join(:inner, :m_header)
    |> Ecto.Query.preload([m_header: m_header], [m_header: m_header])
  end

  @doc false
  def find_f1_22_lap_data_packets_query_preload_m_lapData(q, opts) do
    case Keyword.fetch(opts, :preload_m_lapData) do
      {:ok, true} -> Ecto.Query.preload(q, [:m_lapData])
      _false -> q
    end
  end

  @doc """
  Creates a f1_22_lap_data_packet_car.

  ## Examples

      iex> create_f1_22_lap_data_packet_car(f1_22_lap_data_packet, %{field: value})
      {:ok, %F122LapDataPacketCar{}}

      iex> create_f1_22_lap_data_packet_car(f1_22_lap_data_packet, %{field: bad_value})
      {:error, reason}

  """
  def create_f1_22_lap_data_packet_car(%F122LapDataPacket{} = ld0, %{} = attrs) do
    # attributes
    attrs = Map.put(attrs, :f1_22_lap_data_packet_id, ld0.id)

    # create
    %F122LapDataPacketCar{}
    |> F122LapDataPacketCar.changeset(attrs)
    |> RT.Repo.insert()
  end

  @doc """
  Like `find_f1_22_lap_data_packet_cars/1` except returns a count of the items instead of a list.

  ## Examples

      iex> count_f1_22_lap_data_packet(key: val)
      {:ok, 1}

  """
  def count_f1_22_lap_data_packet_cars(opts \\ []) do
    with {:ok, q} <- query_f1_22_lap_data_packet_cars(opts) do
      [count] = Ecto.Query.select(q, [i], count(i.id)) |> RT.Repo.all()
      {:ok, count}
    end
  end

  @doc """
  Find f1_22_lap_data_packet according to query parameters in `opts`.

  ## Examples

      iex> find_f1_22_lap_data_packets(id: 123)
      [%F122LapDataPacketCar{}, ...]

  """
  def find_f1_22_lap_data_packet_cars(opts \\ []) do
    case find_f1_22_lap_data_packet_cars_query(opts) do
      {:ok, q} ->
        RT.Repo.all(q)
        |> maybe_dedup_f1_22_lap_data_packet_car_frames(opts)
      {:error, reason} ->
        raise "find_f1_22_lap_data_packet_cars: reason=#{inspect reason}"
    end
  end

  @doc """
  Fetch f1_22_lap_data_packet_cars according to query parameters in `opts`.

  ## Examples

      iex> fetch_f1_22_lap_data_packet_cars(id: 123)
      {:ok, [%F122LapDataPacketCar{}, ...]}

  """
  def fetch_f1_22_lap_data_packet_cars(opts \\ []) do
    with {:ok, q} <- find_f1_22_lap_data_packet_cars_query(opts),
      items = RT.Repo.all(q),
      items = maybe_dedup_f1_22_lap_data_packet_car_frames(items, opts),
      do: {:ok, items}
  end

  @doc false
  def find_f1_22_lap_data_packet_cars_query(opts \\ []) do
    with {:ok, q} <- query_f1_22_lap_data_packet_cars(opts),
      {:ok, q} <- RT.Query.find_query_extra(q, opts),
      {:ok, q} <- query_f1_22_lap_data_packet_cars_order_by(q, opts),
      q = find_f1_22_lap_data_packet_cars_query_preload_defaults(q),
      do: {:ok, q}
  end

  @doc false
  def query_f1_22_lap_data_packet_cars(opts \\ []) do
    q = Ecto.Query.from(n in F122LapDataPacketCar)
    with {:ok, q} <- RT.Query.find_query_base(q, opts),
      {:ok, q} <- find_f1_22_lap_data_packets_cars_query_m_sessionUID(q, opts),
      {:ok, q} <- find_f1_22_lap_data_packets_cars_query_car_index(q, opts),
      {:ok, q} <- find_f1_22_lap_data_packets_cars_query_m_currentLapNum(q, opts),
      {:ok, q} <- RT.Query.find_query_m_header_m_frameIdentifier(q, opts),
      do: {:ok, q}
  end

  @doc false
  def find_f1_22_lap_data_packets_cars_query_m_sessionUID(q, opts) do
    case Keyword.fetch(opts, :m_sessionUID) do
      {:ok, val} ->
        q =
          RT.Query.ensure_join(q, :inner, :m_header)
          |> Ecto.Query.where(as(:m_header).m_sessionUID == ^val)
        {:ok, q}
      _not_found ->
        {:ok, q}
    end
  end

  @doc false
  def find_f1_22_lap_data_packets_cars_query_car_index(q, opts) do
    case Keyword.fetch(opts, :car_index) do
      {:ok, val} ->
        q = Ecto.Query.where(q, [i], i.car_index == ^val)
        {:ok, q}
      _not_found ->
        {:ok, q}
    end
  end

  @doc false
  def find_f1_22_lap_data_packets_cars_query_m_currentLapNum(q, opts) do
    case Keyword.fetch(opts, :m_currentLapNum) do
      {:ok, val} -> {:ok, Ecto.Query.where(q, [i], i.m_currentLapNum == ^val)}
      _not_found -> {:ok, q}
    end
  end

  @doc false
  def query_f1_22_lap_data_packet_cars_order_by(q, opts) do
    q = RT.Query.ensure_join(q, :inner, :m_header)
    case Keyword.fetch(opts, :order_by) do
      {:ok, vals} when is_list(vals) -> {:ok, query_f1_22_lap_data_packet_cars_order_by_reduce(vals, q)}
      _not_found -> {:ok, query_f1_22_lap_data_packet_cars_order_by_default(q)}
    end
  end

  defp query_f1_22_lap_data_packet_cars_order_by_default(q) do
    Ecto.Query.order_by(q, [{:asc, as(:m_header).m_frameIdentifier}, {:desc, as(:m_header).m_sessionTime}])
  end

  defp query_f1_22_lap_data_packet_cars_order_by_reduce([], q), do: q
  defp query_f1_22_lap_data_packet_cars_order_by_reduce([{:m_frameIdentifier, :asc}|items], q) do
    q = Ecto.Query.order_by(q, [{:asc, as(:m_header).m_frameIdentifier}])
    query_f1_22_lap_data_packet_cars_order_by_reduce(items, q)
  end
  defp query_f1_22_lap_data_packet_cars_order_by_reduce([{:m_frameIdentifier, :desc}|items], q) do
    q = Ecto.Query.order_by(q, [{:desc, as(:m_header).m_frameIdentifier}])
    query_f1_22_lap_data_packet_cars_order_by_reduce(items, q)
  end
  defp query_f1_22_lap_data_packet_cars_order_by_reduce([{:m_sessionTime, :asc}|items], q) do
    q = Ecto.Query.order_by(q, [{:asc, as(:m_header).m_sessionTime}])
    query_f1_22_lap_data_packet_cars_order_by_reduce(items, q)
  end
  defp query_f1_22_lap_data_packet_cars_order_by_reduce([{:m_sessionTime, :desc}|items], q) do
    q = Ecto.Query.order_by(q, [{:desc, as(:m_header).m_sessionTime}])
    query_f1_22_lap_data_packet_cars_order_by_reduce(items, q)
  end
  defp query_f1_22_lap_data_packet_cars_order_by_reduce([_item|items], q) do
    query_f1_22_lap_data_packet_cars_order_by_reduce(items, q)
  end

  @doc false
  def find_f1_22_lap_data_packet_cars_query_preload_defaults(q) do
    q
    |> RT.Query.ensure_join(:inner, :m_header)
    |> Ecto.Query.preload([m_header: m_header], [m_header: m_header])
  end

  @doc false
  def maybe_dedup_f1_22_lap_data_packet_car_frames(items, opts \\ []) do
    case Keyword.get(opts, :dedup_m_frameIdentifier) do
      true -> dedup_f1_22_lap_data_packet_car_frames(items)
      _false -> items
    end
  end

  @doc """
  Fetch one f1_22_lap_data_packet_car according to opts.

  """
  def fetch_one_f1_22_lap_data_packet_car(opts \\ []) do
    with {:ok, result} <- fetch_f1_22_lap_data_packet_cars(opts),
      do: RT.Query.parse_fetch_one_result(result, :f1_22_lap_data_packet_car)
  end

  @doc false
  def dedup_f1_22_lap_data_packet_car_frames(items) do
    Enum.dedup_by(items, fn i -> i.m_header.m_frameIdentifier end)
  end


  @doc """
  Fetch the first and last f1_22_lap_data_packet_car records for the given session, car_index, and lap_number.

  """
  def fetch_f1_22_lap_data_packet_car_lap_first_and_last(m_sessionUID, car_index, lap_number) do
    # # first packet of lap
    # first_opts = [
    #   m_sessionUID: m_sessionUID,
    #   car_index: car_index,
    #   m_currentLapNum: lap_number,
    #   limit: 1,
    #   order_by: [{:m_frameIdentifier, :asc}, {:m_sessionTime, :desc}],
    # ]
    # # last packet of lap
    # last_opts = [
    #   m_sessionUID: m_sessionUID,
    #   car_index: car_index,
    #   m_currentLapNum: lap_number,
    #   limit: 1,
    #   order_by: [{:m_frameIdentifier, :desc}, {:m_sessionTime, :desc}],
    # ]
    # # lookup
    # with {:ok, first_record} <- fetch_f1_22_lap_data_packet_car_lap_first(m_sessionUID, car_index, lap_number),
    #   {:ok, last_record} <- fetch_one_f1_22_lap_data_packet_car(last_opts),
    #   do: {:ok, %{first: first_record, last: last_record}}

    with {:ok, first_record} <- fetch_f1_22_lap_data_packet_car_lap_first(m_sessionUID, car_index, lap_number),
      {:ok, last_record} <- fetch_f1_22_lap_data_packet_car_lap_last(m_sessionUID, car_index, lap_number),
      do: {:ok, %{first: first_record, last: last_record}}
  end

  @doc false
  def fetch_f1_22_lap_data_packet_car_lap_first(m_sessionUID, car_index, lap_number) do
    # first packet of lap
    first_opts = [
      m_sessionUID: m_sessionUID,
      car_index: car_index,
      m_currentLapNum: lap_number,
      limit: 1,
      order_by: [{:m_frameIdentifier, :asc}, {:m_sessionTime, :desc}],
    ]
    case fetch_one_f1_22_lap_data_packet_car(first_opts) do
      {:ok, item} -> {:ok, item}
      {:error, %{not_found: _}} -> {:error, %{not_found: ["f1_22_lap_data_packet_car: first not found"]}}
    end
  end

  @doc false
  def fetch_f1_22_lap_data_packet_car_lap_last(m_sessionUID, car_index, lap_number) do
    # last packet of lap
    last_opts = [
      m_sessionUID: m_sessionUID,
      car_index: car_index,
      m_currentLapNum: lap_number,
      limit: 1,
      order_by: [{:m_frameIdentifier, :desc}, {:m_sessionTime, :desc}],
    ]
    case fetch_one_f1_22_lap_data_packet_car(last_opts) do
      {:ok, item} -> {:ok, item}
      {:error, %{not_found: _}} -> {:error, %{not_found: ["f1_22_lap_data_packet_car: last not found"]}}
    end
  end

  @doc """
  Find the f1_22_lap_data_packet_car records for the given session, car_index, and lap_number.

  """
  def find_f1_22_lap_data_packet_car_lap_records(m_sessionUID, car_index, lap_number) do
    opts = [
      m_sessionUID: m_sessionUID,
      car_index: car_index,
      m_currentLapNum: lap_number,
      dedup_m_frameIdentifier: true,
      order_by: [{:m_frameIdentifier, :asc}, {:m_sessionTime, :desc}],
    ]
    find_f1_22_lap_data_packet_cars(opts)
    |> filter_linear_distance()
    |> Enum.sort_by(fn i ->
      {i.m_totalDistance, i.m_currentLapNum, i.m_header.m_frameIdentifier, i.m_header.m_sessionTime, i.serial_number}
    end)
  end

  @doc false
  def filter_linear_distance(items) do
    # require m_totalDistance to move in one direction
    items =
      Enum.sort_by(items, fn i ->
        {i.m_totalDistance, i.m_currentLapNum, i.m_header.m_frameIdentifier, i.m_header.m_sessionTime}
      end)
      |> Enum.reverse()

    item_0 = Enum.at(items, 0)
    filter_linear_distance(items, Enum.at(items, 0), [])
  end
  def filter_linear_distance([], _cursor, accum) do
    # done
    accum
  end
  def filter_linear_distance([item|items], cursor, accum) do
    # m_totalDistance to always move in the same direction (e.g. must always decrease as time moves backward)
    conditions = [
      (item.m_totalDistance <= cursor.m_totalDistance),
      (item.m_currentLapNum <= cursor.m_currentLapNum),
      (item.m_header.m_frameIdentifier <= cursor.m_header.m_frameIdentifier),
      (item.m_header.m_sessionTime <= cursor.m_header.m_sessionTime),
    ]
    case Enum.all?(conditions) do
      # next distance is linear
      true -> filter_linear_distance(items, item, [item|accum])

      # next distance is not linear
      false -> filter_linear_distance(items, cursor, accum)
    end
  end

end

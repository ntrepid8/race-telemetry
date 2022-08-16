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
    with {:ok, q} <- find_f1_22_lap_data_packet_cars_query(opts) do
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
    case fetch_f1_22_lap_data_packet_cars(opts) do
      {:ok, items} -> items
      {:error, reason} -> raise "find_f1_22_lap_data_packet_cars: reason=#{inspect reason}"
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
      {:ok, q} <- RT.Query.find_query_extra(q, opts),
      q = find_f1_22_lap_data_packet_cars_query_order_by(q),
      q = find_f1_22_lap_data_packet_cars_query_preload_defaults(q),
      do: {:ok, RT.Repo.all(q)}
  end

  @doc false
  def find_f1_22_lap_data_packet_cars_query(opts \\ []) do
    q = Ecto.Query.from(n in F122LapDataPacketCar)
    with {:ok, q} <- RT.Query.find_query_base(q, opts),
      {:ok, q} <- find_f1_22_lap_data_packets_cars_query_m_sessionUID(q, opts),
      {:ok, q} <- find_f1_22_lap_data_packets_cars_query_car_index(q, opts),
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
  def find_f1_22_lap_data_packet_cars_query_order_by(q) do
    q
    |> RT.Query.ensure_join(:inner, :m_header)
    |> Ecto.Query.order_by([{:asc, as(:m_header).m_sessionTime}, {:asc, as(:m_header).m_frameIdentifier}])
  end

  @doc false
  def find_f1_22_lap_data_packet_cars_query_preload_defaults(q) do
    q
    |> RT.Query.ensure_join(:inner, :m_header)
    |> Ecto.Query.preload([m_header: m_header], [m_header: m_header])
  end

end

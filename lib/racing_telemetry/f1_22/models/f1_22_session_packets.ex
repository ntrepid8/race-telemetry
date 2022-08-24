defmodule RacingTelemetry.F122.Models.F122SessionPackets do
  @moduledoc """
  The F122SessionPackets context.

  """
  use RacingTelemetry.Query
  require Logger
  alias RacingTelemetry, as: RT
  alias RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader
  alias RacingTelemetry.F122.Models.F122SessionPackets.{
    F122SessionPacket,
  }

  @f1_22_session_packet_preloads [:m_marshalZones, :m_weatherForecastSamples, :m_header]

  @doc """
  Creates a f1_22_session_packet.

  ## Examples

      iex> create_f1_22_session_packet(%{field: value})
      {:ok, %F122SessionPacket{}}

      iex> create_f1_22_session_packet(%{field: bad_value})
      {:error, reason}

  """
  def create_f1_22_session_packet(%{} = attrs) do
    # create
    %F122SessionPacket{}
    |> F122SessionPacket.changeset(attrs)
    |> RT.Repo.insert()
    |> case do
      {:ok, item} -> {:ok, preload_f1_22_session_packet(item)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc false
  def preload_f1_22_session_packet(%F122SessionPacket{} = ld0, opts \\ []) do
    RT.Repo.preload(ld0, @f1_22_session_packet_preloads, opts)
  end

  @doc """
  Updates a f1_22_session_packet.

  ## Examples

      iex> update_f1_22_session_packet(f1_22_session_packet, %{field: value})
      {:ok, %F122SessionPacket{}}

      iex> update_f1_22_session_packet(f1_22_session_packet, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_f1_22_session_packet(%F122SessionPacket{} = ls0, %{} = attrs) do
    # update
    F122SessionPacket.changeset(ls0, attrs)
    |> RT.Repo.update()
    |> case do
      {:ok, item} -> {:ok, preload_f1_22_session_packet(item)}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Like `find_f1_22_session_packets/1` except returns a count of the items instead of a list.

  ## Examples

      iex> count_f1_22_session_packets(key: val)
      {:ok, 1}

  """
  def count_f1_22_session_packets(opts \\ []) do
    with {:ok, q} <- query_f1_22_session_packets(opts) do
      [count] = Ecto.Query.select(q, [i], count(i.id)) |> RT.Repo.all()
      {:ok, count}
    end
  end

  @doc """
  Find f1_22_session_packets according to query parameters in `opts`.

  ## Examples

      iex> find_f1_22_session_packets(id: 123)
      [%F122SessionPacket{}, ...]

  """
  def find_f1_22_session_packets(opts \\ []) do
    case fetch_f1_22_session_packets(opts) do
      {:ok, items} -> items
      {:error, reason} -> raise "find_f1_22_session_packets: reason=#{inspect reason}"
    end
  end

  @doc """
  Fetch f1_22_session_packets according to query parameters in `opts`.

  ## Examples

      iex> fetch_f1_22_car_telemetry_packet_cars(id: 123)
      {:ok, [%F122SessionPacket{}, ...]}

  """
  def fetch_f1_22_session_packets(opts \\ []) do
     with {:ok, q} <- query_f1_22_session_packets(opts),
      {:ok, q} <- RT.Query.find_query_extra(q, opts),
      {:ok, q} <- query_f1_22_session_packets_preload_all(q, opts),
      {:ok, q} <- query_f1_22_session_packets_order_by(q, opts),
      q = RT.Query.find_query_m_header_preload_defaults(q),
      items = RT.Repo.all(q),
      do: {:ok, items}
  end

  @doc false
  def query_f1_22_session_packets(opts \\ []) do
    q = Ecto.Query.from(n in F122SessionPacket)
    with {:ok, q} <- RT.Query.find_query_base(q, opts),
      {:ok, q} <- RT.Query.find_query_m_header_m_sessionUID(q, opts),
      {:ok, q} <- RT.Query.find_query_m_header_m_frameIdentifier(q, opts),
      {:ok, q} <- RT.Query.find_query_m_header_m_frameIdentifier_gte(q, opts),
      {:ok, q} <- RT.Query.find_query_m_header_m_frameIdentifier_lte(q, opts),
      do: {:ok, q}
  end

  defp query_f1_22_session_packets_preload_all(q, opts) do
    case Keyword.fetch(opts, :preload_all) do
      {:ok, true} -> {:ok, Ecto.Query.preload(q, ^@f1_22_session_packet_preloads)}
      {:ok, false} -> {:ok, q}
      {:ok, _val} -> {:error, %{preload_all: ["is invalid"]}}
      :error -> {:ok, q}
    end
  end

  defp query_f1_22_session_packets_order_by(q, opts) do
    case Keyword.fetch(opts, :order_by) do
      {:ok, :m_sessionUID} ->
        q =
          RT.Query.ensure_join(q, :inner, :m_header)
          |> Ecto.Query.order_by([i], [
            {:asc, as(:m_header).m_sessionUID},
            {:asc, as(:m_header).m_frameIdentifier},
            {:asc, as(:m_header).m_sessionTime},
            {:asc, i.serial_number},
          ])
        {:ok, q}

      {:ok, :m_frameIdentifier} ->
        q =
          RT.Query.ensure_join(q, :inner, :m_header)
          |> Ecto.Query.order_by([i], [
            {:asc, as(:m_header).m_frameIdentifier},
            {:asc, as(:m_header).m_sessionTime},
            {:asc, i.serial_number},
          ])
        {:ok, q}

      {:ok, _val} ->
        {:error, %{order_by: ["is invalid"]}}

      :error ->
        {:ok, Ecto.Query.order_by(q, [i], [{:asc, i.serial_number}])}
    end
  end

  @doc """
  Fetch a single f1_22_session_packet according to opts.

  ## Examples

      iex> fetch_one_f1_22_session_packet(id: 123)
      {:ok, %F122SessionPacket{}}

      iex> fetch_one_f1_22_session_packet(id: 456)
      {:error, :not_found}

  """
  def fetch_one_f1_22_session_packet(opts \\ []) do
    with {:ok, items} <- fetch_f1_22_session_packets(opts),
      do: RT.Query.parse_fetch_one_result(items, :f1_22_session_packet)
  end

  @doc """
  Fetch a f1_22_session_packet.

  ## Examples

      iex> fetch_f1_22_session_packet(123)
      {:ok, %F122SessionPacket{}}

      iex> fetch_f1_22_session_packet(456)
      {:error, :not_found}

  """
  def fetch_f1_22_session_packet(id, opts \\ []) do
    Keyword.put(opts, :id, id)
    |> fetch_one_f1_22_session_packet()
  end

  @doc """
  Deletes a f1_22_session_packet.

  ## Examples

      iex> delete_f1_22_session_packet(f1_22_session_packet)
      {:ok, %F122SessionPacket{}}

      iex> delete_f1_22_session_packet(f1_22_session_packet)
      {:error, %Ecto.Changeset{}}

  """
  def delete_f1_22_session_packet(%F122SessionPacket{} = f1_22_session_packet) do
    RT.Repo.delete(f1_22_session_packet)
  end

  @doc """
  Returns a list of the final f1_22_session_packets for each unique m_sessionUID.

  """
  def fetch_unique_f1_22_session_packets_by_m_sessionUID(opts \\ []) do
    # find list of f1_22_session_packet ids for the final packets for each session
    f1_22_session_packet_ids =
      Ecto.Query.from(i in F122SessionPacket)
      |> RT.Query.ensure_join(:inner, :m_header)
      |> Ecto.Query.distinct([as(:m_header).m_sessionUID])
      |> Ecto.Query.order_by([i], [asc: i.inserted_at])
      |> Ecto.Query.select([i], [i.id])
      |> RT.Repo.all()
      |> Enum.map(fn [id] -> id end)

    # find each of the unique IDs
    Keyword.put(opts, :ids, f1_22_session_packet_ids)
    |> fetch_f1_22_session_packets()
  end

end

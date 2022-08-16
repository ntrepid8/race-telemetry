defmodule RacingTelemetry.F122.Models.F122PacketHeaders do
  @moduledoc """
  The F122PacketHeaders context.

  """
  use RacingTelemetry.Query
  require Logger
  alias RacingTelemetry, as: RT
  alias RacingTelemetry.F122.Models.F122PacketHeaders.F122PacketHeader


  @doc """
  Creates a f1_22_packet_header.

  ## Examples

      iex> create_f1_22_packet_header(%{field: value})
      {:ok, %{f1_22_packet_header: %F122PacketHeader{}}}

      iex> create_f1_22_packet_header(%{field: bad_value})
      {:error, %{f1_22_packet_header: %Ecto.Changeset{}}}

  """
  def create_f1_22_packet_header(%{} = attrs) do
    # create
    %F122PacketHeader{}
    |> F122PacketHeader.changeset(attrs)
    |> RT.Repo.insert()
  end

  @doc """
  Updates a f1_22_packet_header.

  ## Examples

      iex> update_f1_22_packet_header(f1_22_packet_header, %{field: value})
      {:ok, %F122PacketHeader{}}

      iex> update_f1_22_packet_header(f1_22_packet_header, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_f1_22_packet_header(%F122PacketHeader{} = f1_22_packet_header, %{} = attrs) do
    f1_22_packet_header
    |> F122PacketHeader.changeset(attrs)
    |> RT.Repo.update()
  end

  @doc """
  Like `find_f1_22_packet_headers/1` except returns a count of the items instead of a list.

  ## Examples

      iex> count_f1_22_packet_headers(key: val)
      {:ok, 1}

  """
  def count_f1_22_packet_headers(opts \\ []) do
    with {:ok, q} <- find_f1_22_packet_headers_query(opts) do
      [count] = Ecto.Query.select(q, [i], count(i.id)) |> RT.Repo.all()
      {:ok, count}
    end
  end

  @doc """
  Find f1_22_packet_headers according to query parameters in `opts`.

  ## Examples

      iex> find_f1_22_packet_headers(id: 123)
      {:ok, [%F122PacketHeader{}, ...]}

  """
  def find_f1_22_packet_headers(opts \\ []) do
    with {:ok, q} <- find_f1_22_packet_headers_query(opts),
      {:ok, q} <- RT.Query.find_query_extra(q, opts),
      do: {:ok, RT.Repo.all(q)}
  end

  @doc false
  def find_f1_22_packet_headers_query(opts \\ []) do
    q = Ecto.Query.from(n in F122PacketHeader)
    with {:ok, q} <- RT.Query.find_query_base(q, opts),
      {:ok, q} <- find_f1_22_packet_headers_query_m_sessionUID(q, opts),
      do: {:ok, q}
  end

  @doc false
  def find_f1_22_packet_headers_query_m_sessionUID(q, opts) do
    case Keyword.fetch(opts, :m_sessionUID) do
      {:ok, val} -> {:ok, Ecto.Query.where(q, [i], i.m_sessionUID == ^val)}
      _not_found -> {:ok, q}
    end
  end

  @doc """
  Fetch a single f1_22_packet_header according to opts.

  ## Examples

      iex> fetch_one_f1_22_packet_header(id: 123)
      {:ok, %F122PacketHeader{}}

      iex> fetch_one_f1_22_packet_header(id: 456)
      {:error, :not_found}

  """
  def fetch_one_f1_22_packet_header(opts \\ []) do
    with {:ok, items} <- find_f1_22_packet_headers(opts),
      do: RT.Query.parse_fetch_one_result(items, :f1_22_packet_header)
  end

  @doc """
  Fetch a f1_22_packet_header.

  ## Examples

      iex> fetch_f1_22_packet_header(123)
      {:ok, %F122PacketHeader{}}

      iex> fetch_f1_22_packet_header(456)
      {:error, :not_found}

  """
  def fetch_f1_22_packet_header(id, opts \\ []) do
    Keyword.put(opts, :id, id)
    |> fetch_one_f1_22_packet_header()
  end

  @doc """
  Deletes a f1_22_packet_header.

  ## Examples

      iex> delete_f1_22_packet_header(f1_22_packet_header)
      {:ok, %F122PacketHeader{}}

      iex> delete_f1_22_packet_header(f1_22_packet_header)
      {:error, %Ecto.Changeset{}}

  """
  def delete_f1_22_packet_header(%F122PacketHeader{} = f1_22_packet_header) do
    RT.Repo.delete(f1_22_packet_header)
  end

end

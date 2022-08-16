defmodule RacingTelemetry.Query do
  @moduledoc """
  Query macro helpers.

  Use like this:
  ```
  use RacingTelemetry.Query
  ```

  """
  import Ecto.Query, warn: false
  alias RacingTelemetry.QueryOptions, as: RTQO


  defmacro __using__(_) do
    quote do
      import Ecto.Query, warn: false
    end
  end


  @doc """
  Ensure that an association is joined as a named binding.

  ## Examples

      iex> ensure_join(query, :inner, :f1_22_header)
      %Ecto.Query{}

  """
  defmacro ensure_join(query, join, binding) do
    quote do
      case Ecto.Query.has_named_binding?(unquote(query), unquote(binding)) do
        true ->
          unquote(query)
        false ->
          Ecto.Query.join(unquote(query), unquote(join), [i], j in assoc(i, unquote(binding)), as: unquote(binding))
      end
    end
  end

  @doc """
  Parse query results into the format expected for `fetch` functions.

  This is provided to make it easier to reuse code from this file
  in custom `fetch` functions defined for individual context modules.

  """
  def parse_fetch_one_result(result, key) do
    case result do
      # Success
      [item] -> {:ok, item}
      # This should never happen outside of a developer error.
      [_h|_t] -> {:error, Map.put(%{}, key, ["multiple found"])}
      # Error, item not found
      _ -> {:error, Map.put(%{}, key, ["not found"])}
    end
  end

  @doc """
  Add basic query options to the given query.

  This version only applies options that are allowed with aggregations such as count.

  """
  def find_query_base(query, opts) do
    with {:ok, query} <- RTQO.find_query_id(query, opts),
      {:ok, query} <- RTQO.find_query_deleted(query, opts),
      {:ok, query} <- RTQO.find_query_live_mode(query, opts),
      do: {:ok, query}
  end

  @doc """
  Add extra query options to the given query.

  This version applies all options from `find_query_slim/1` and adds preload, offset, and limit.
  """
  def find_query_extra(query, opts) do
    with {:ok, query} <- RTQO.find_query_preload(query, opts),
      {:ok, query} <- RTQO.find_query_limit(query, opts),
      {:ok, query} <- RTQO.find_query_offset(query, opts),
      do: {:ok, query}
  end

end

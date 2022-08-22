defmodule RacingTelemetry.QueryOptions do
  @moduledoc """
  Query option helpers.

  """
  use RacingTelemetry.Query


  @doc false
  def find_query_id(query, opts) do
    with {:ok, val} <- Keyword.fetch(opts, :id),
      {:ok, val} <- validate_uuid(:id, val)
    do
      {:ok, Ecto.Query.where(query, [i], i.id == ^val)}
    else
      :error -> {:ok, query}
      error -> error
    end
  end

  @doc false
  def validate_uuid(field_name, val) do
    case UUID.info(val) do
      {:ok, _} -> {:ok, val}
      _error -> {:error, Map.put(%{}, field_name, ["is not a valid UUID"])}
    end
  end

  @doc false
  def find_query_deleted(query, opts) do
    case Keyword.fetch(opts, :deleted) do
      {:ok, :any} -> {:ok, Ecto.Query.where(query, [i], i.deleted == true or i.deleted == false)}
      {:ok, true} -> {:ok, Ecto.Query.where(query, [i], i.deleted == true)}
      {:ok, false} -> {:ok, Ecto.Query.where(query, [i], i.deleted == false)}
      {:ok, _val} -> {:error, Map.put(%{}, :deleted, ["is not a valid boolean"])}
      :error -> {:ok, Ecto.Query.where(query, [i], i.deleted == false)}
    end
  end

  @doc false
  def find_query_live_mode(query, opts) do
    case Keyword.fetch(opts, :live_mode) do
      {:ok, :any} -> {:ok, Ecto.Query.where(query, [i], i.live_mode == true or i.live_mode == false)}
      {:ok, true} -> {:ok, Ecto.Query.where(query, [i], i.live_mode == true)}
      {:ok, false} -> {:ok, Ecto.Query.where(query, [i], i.live_mode == false)}
      {:ok, _val} -> {:error, Map.put(%{}, :live_mode, ["is not a valid boolean"])}
      :error -> {:ok, Ecto.Query.where(query, [i], i.live_mode == true)}
    end
  end

  @doc false
  def find_query_preload(query, opts) do
    case Keyword.fetch(opts, :preload) do
      {:ok, val} when is_list(val) -> {:ok, Ecto.Query.preload(query, ^val)}
      {:ok, _val} -> {:error, Map.put(%{}, :preload, ["is not a valid list"])}
      :error -> {:ok, query}
    end
  end

  @doc false
  def find_query_limit(query, opts) do
    case Keyword.fetch(opts, :limit) do
      {:ok, nil} -> {:ok, query}
      {:ok, 0} -> {:ok, query}
      {:ok, val} when is_integer(val) -> {:ok, Ecto.Query.limit(query, ^val)}
      {:ok, _val} -> {:error, Map.put(%{}, :limit, ["is not a valid integer"])}
      :error -> {:ok, query}
    end
  end

  @doc false
  def find_query_offset(query, opts) do
    case Keyword.fetch(opts, :offset) do
      {:ok, nil} -> {:ok, query}
      {:ok, 0} -> {:ok, query}
      {:ok, val} when is_integer(val) -> {:ok, Ecto.Query.offset(query, ^val)}
      {:ok, _val} -> {:error, Map.put(%{}, :offset, ["is not a valid integer"])}
      :error -> {:ok, query}
    end
  end

end

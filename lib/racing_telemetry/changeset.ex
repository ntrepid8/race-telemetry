defmodule RacingTelemetry.Changeset do
  @moduledoc """
  Helpers for working with `Ecto.Changeset` structures.

  """

  @doc """
  Format the errors in a changeset into a map that can be serialized.

  """
  def format_changeset_errors(%Ecto.Changeset{} = changeset_with_errors) do
    Ecto.Changeset.traverse_errors(changeset_with_errors, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

end

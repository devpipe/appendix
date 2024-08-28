defmodule Appendix.Jsonb do
  @moduledoc """
  A module for building Ecto queries with JSONB columns.

  This module provides a macro `json_query/4` to generate dynamic where clauses
  for JSONB columns in an Ecto query.
  """

  import Ecto.Query

  @doc """
  Builds a dynamic where clause for JSONB columns in an Ecto query.

  ## Parameters
    - qry: The initial query.
    - col: The JSONB column to query.
    - params: A keyword list of key-value pairs to match against the JSONB column.
    - opts: A keyword list of options. Supports `:where_type`, which can be `:where` or `:or_where`. Defaults to `:where`.

  ## Examples

      iex> import Ecto.Query
      iex> query = from(p in Post)
      iex> json_query(query, :metadata, [title: "Elixir", author: "José"], where_type: :where)
      # Ecto query with JSONB where clauses
  """
  defmacro json_query(qry, col, params, opts) do
    where_type = Keyword.get(opts, :where_type, :where)

    quote do
      Enum.reduce(unquote(params), unquote(qry), fn {key, val}, acc ->
        from(q in acc, [
          {
            unquote(where_type),
            fragment(
              "?::jsonb @> ?::jsonb",
              field(q, ^unquote(col)),
              ^%{to_string(key) => val}
            )
          }
        ])
      end)
    end
  end
end

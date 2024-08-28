defmodule Appendix.Namespace do
  @moduledoc """
  A module for defining namespaced routes in Plug applications. This module provides
  macros for organizing routes under a common path, similar to Phoenix's pipelines
  but scoped to a specific route.
  """

  @doc """
  Defines a namespace for a group of routes under the given path. The `namespace`
  macro allows you to group related routes and apply common plugs to all routes
  within the namespace.

  ## Parameters

    - `path`: The base path for the namespace (e.g., `"/api"`).
    - `do: block`: The block of code containing the routes and plugs to be applied
      within the namespace.

  ## Example

      namespace "/api" do
        plug Plug.Logger

        get "/status" do
          send_resp(conn, 200, "API is up and running")
        end
      end
  """
  defmacro namespace(path, do: block) do
    quote do
      # Modify the path of each route within the block to prepend the namespace
      @plug_builder_opts %{path: unquote(path)}

      defp __namespace_path__(conn, opts) do
        %{conn | request_path: opts[:path] <> conn.request_path}
      end

      plug(:__namespace_path__)

      unquote(block)
    end
  end
end

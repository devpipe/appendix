defmodule Namespace do
  @moduledoc """
  A module for defining namespaced routes in Plug applications. This module provides
  macros for organizing routes under a common path, similar to Phoenix's pipelines
  but scoped to a specific route.

  ## Example

      defmodule MyApp.Router do
        use Plug.Router
        import Namespace

        plug :match
        plug :dispatch

        def api_namespace do
          plug :put_resp_content_type, "application/json"
        end

        namespace "/api" do
          plug Plug.Logger
          plug :api_namespace
          plug :auth_required

          get "/" do
            send_resp(conn, 200, ~s({"message": "Welcome to the API"}))
          end
        end

        match _ do
          send_resp(conn, 404, "Oops!")
        end

        defp put_resp_content_type(conn, type) do
          Plug.Conn.put_resp_content_type(conn, type)
        end

        defp auth_required(conn) do
          if get_req_header(conn, "authorization") == ["Bearer valid_token"] do
            conn
          else
            conn
            |> Plug.Conn.send_resp(401, "Unauthorized")
            |> halt()
          end
        end
      end
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
      path = unquote(path)

      plug = fn conn, opts ->
        # Prepend the namespace path to the request path
        %{conn | request_path: path <> conn.request_path}
        |> Plug.Builder.run(opts)
      end

      # Dynamically define the plugs and routes within the namespace
      unquote(block)
    end
  end

  @doc """
  A helper macro for `namespace/2` that applies the given path to all routes
  defined within the block. This macro is not typically used directly but is
  used by the `namespace/2` macro to handle path scoping.

  ## Parameters

    - `path`: The path to be prepended to all routes in the block.
    - `do: block`: The block of code containing the routes and plugs to be scoped.

  ## Example

      scope "/admin" do
        get "/dashboard" do
          send_resp(conn, 200, "Admin Dashboard")
        end
      end
  """
  defmacro scope(path, do: block) do
    quote do
      path = unquote(path)

      plug = fn conn, opts ->
        # Prepend the scope path to the request path
        %{conn | request_path: path <> conn.request_path}
        |> Plug.Builder.run(opts)
      end

      # Dynamically define the plugs and routes within the scope
      unquote(block)
    end
  end
end

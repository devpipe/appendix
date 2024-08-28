defmodule Appendix.Router do
  @moduledoc """
  A module for defining common Plug router configurations.

  This module provides a macro `__using__/1` to include common router settings,
  such as required imports, plugs, and necessary configurations for handling requests.
  """

  @doc """
  A macro to set up common configurations for Plug routers.

  This macro includes required imports, setups for parsers, and uses necessary modules
  like `Plug.Router` and `Responses`.

  ## Examples

      defmodule MyRouter do
        use Router

        plug :match
        plug :dispatch

        get "/" do
          send_resp(conn, 200, "Welcome")
        end

        match _ do
          send_resp(conn, 404, "Not Found")
        end
      end
  """
  defmacro __using__(_) do
    quote do
      require Logger
      import Plug.Conn

      use Plug.Router
      use Appendix.Response

      import unquote(__MODULE__)

      plug(Plug.Parsers,
        parsers: [:urlencoded, :multipart, :json],
        pass: ["*/*"],
        json_decoder: Jason
      )
    end
  end
end

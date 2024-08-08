defmodule Responses do
  @moduledoc """
  A module providing wrappers for common HTTP responses in Plug applications.

  This module includes functions to send JSON, HTML, text, file responses, and more.
  It also provides utilities for handling Ecto changeset errors and redirecting requests.
  """

  require Logger
  alias Ecto.Changeset

  @doc """
  Sets up common imports for modules using `Responses`.

  This macro imports `Plug.Conn` and the current module for easy access to response helpers.

  ## Examples

      defmodule MyRouter do
        use Plug.Router
        use Responses

        plug :match
        plug :dispatch

        get "/" do
          conn |> json(:ok, %{hello: "world"})
        end
      end
  """
  defmacro __using__(_) do
    quote do
      import Plug.Conn
      import unquote(__MODULE__)
    end
  end

  @doc """
  Sends a JSON response.

  ## Parameters
    - conn: HTTP connection to send the response to.
    - status: Atom or number that represents the HTTP response code.
    - data: Struct to be encoded to JSON as the response body.
    - opts: Keyword list of options. Supports `:resp_headers` to add response headers.

  ## Examples

      conn |> json(:ok, %{hello: "World"})
      conn |> json(:ok, %{hello: "World"}, resp_headers: %{"x-foo" => "bar"})
  """
  def json(conn, status, data, opts \\ []) do
    resp_headers = Keyword.get(opts, :resp_headers, [])
    do_json(conn, status, data, resp_headers)
  end

  defp do_json(conn, status, data, resp_headers) do
    conn
    |> Plug.Conn.merge_resp_headers(resp_headers)
    |> Plug.Conn.put_resp_content_type("application/json")
    |> Plug.Conn.send_resp(status, Jason.encode_to_iodata!(data))
    |> Plug.Conn.halt()
  end

  @doc """
  Sends an HTML response.

  ## Parameters
    - conn: HTTP connection to send the response to.
    - status: Atom or number that represents the HTTP response code.
    - data: HTML string set as the response body.
    - opts: Keyword list of options. Supports `:resp_headers` to add response headers.

  ## Examples

      conn |> html(:ok, "<h1>Hello World</h1>")
      conn |> html(:ok, "<h1>Hello World</h1>", resp_headers: %{"x-foo" => "bar"})
  """
  def html(conn, status, data, opts \\ []) do
    resp_headers = Keyword.get(opts, :resp_headers, [])
    do_html(conn, status, data, resp_headers)
  end

  defp do_html(conn, status, data, resp_headers) do
    conn
    |> Plug.Conn.merge_resp_headers(resp_headers)
    |> Plug.Conn.put_resp_content_type("text/html")
    |> Plug.Conn.send_resp(status, to_string(data))
    |> Plug.Conn.halt()
  end

  @doc """
  Sends a text response.

  ## Parameters
    - conn: HTTP connection to send the response to.
    - status: Atom or number that represents the HTTP response code.
    - data: Text string set as the response body.
    - opts: Keyword list of options. Supports `:resp_headers` to add response headers.

  ## Examples

      conn |> text(:ok, "Hello World!")
      conn |> text(:ok, "Hello World!", resp_headers: %{"x-foo" => "bar"})
  """
  def text(conn, status, data, opts \\ []) do
    resp_headers = Keyword.get(opts, :resp_headers, [])
    do_text(conn, status, data, resp_headers)
  end

  defp do_text(conn, status, data, resp_headers) do
    conn
    |> Plug.Conn.merge_resp_headers(resp_headers)
    |> Plug.Conn.put_resp_content_type("text/plain")
    |> Plug.Conn.send_resp(status, to_string(data))
    |> Plug.Conn.halt()
  end

  @doc """
  Sends a file response.

  ## Parameters
    - conn: HTTP connection to send the response to.
    - path: File path for the file response.
    - opts: Keyword list of options. Supports `:resp_headers` to add response headers.

  ## Examples

      conn |> file(:ok, "/path/to/file")
      conn |> file(:ok, "/path/to/file", resp_headers: %{"x-foo" => "bar"})
  """
  def file(conn, path, opts \\ []) do
    resp_headers = Keyword.get(opts, :resp_headers, [])

    if File.exists?(path) do
      conn
      |> do_file(:ok, path, resp_headers)
    else
      conn
      |> status(:not_found)
    end
  end

  defp do_file(conn, status, path, resp_headers) do
    stat = File.stat!(path, time: :posix)

    conn
    |> Plug.Conn.merge_resp_headers(resp_headers)
    |> Plug.Conn.put_resp_content_type(:mimerl.filename(path))
    |> Plug.Conn.put_resp_header("content-length", "#{stat.size}")
    |> Plug.Conn.put_resp_header("content-transfer-encoding", "binary")
    |> Plug.Conn.put_resp_header("cache-control", "must-revalidate, post-check=0, pre-check=0")
    |> Plug.Conn.send_file(status, path)
  end

  @doc """
  Sends a file download response.

  ## Parameters
    - conn: HTTP connection to send the response to.
    - path: File path for the file response.
    - opts: Keyword list of options. Supports `:resp_headers` to add response headers.

  ## Examples

      conn |> download(:ok, "/path/to/file")
      conn |> download(:ok, "/path/to/file", resp_headers: %{"x-foo" => "bar"})
  """
  def download(conn, path, opts \\ []) do
    resp_headers = Keyword.get(opts, :resp_headers, [])

    if File.exists?(path) do
      conn
      |> do_download(:ok, path, resp_headers)
    else
      conn
      |> status(:not_found)
    end
  end

  defp do_download(conn, status, path, resp_headers) do
    stat = File.stat!(path, time: :posix)

    conn
    |> Plug.Conn.merge_resp_headers(resp_headers)
    |> Plug.Conn.put_resp_header("content-disposition", "attachment; filename=#{Path.basename(path)}")
    |> Plug.Conn.put_resp_content_type(:mimerl.filename(path))
    |> Plug.Conn.put_resp_header("content-length", "#{stat.size}")
    |> Plug.Conn.put_resp_header("content-transfer-encoding", "binary")
    |> Plug.Conn.put_resp_header("cache-control", "must-revalidate, post-check=0, pre-check=0")
    |> Plug.Conn.send_file(status, path)
  end

  @doc """
  Sends a status-only response.

  ## Parameters
    - conn: HTTP connection to send the response to.
    - status: Atom or number that represents the HTTP response code.
    - opts: Keyword list of options. Supports `:resp_headers` to add response headers.

  ## Example

      conn |> status(:ok)
  """
  def status(conn, status, opts \\ []) do
    resp_headers = Keyword.get(opts, :resp_headers, [])
    do_status(conn, status, resp_headers)
  end

  defp do_status(conn, status, resp_headers) do
    conn
    |> Plug.Conn.merge_resp_headers(resp_headers)
    |> Plug.Conn.send_resp(status, "")
    |> Plug.Conn.halt()
  end

  @doc """
  Redirects the request.

  ## Parameters
    - conn: HTTP connection to redirect.
    - status: Atom or number that represents the HTTP response code.
    - url: String representing the URL/URI destination.

  ## Examples

      conn |> redirect("http://example.com/")
      conn |> redirect(301, "http://example.com/")
  """
  def redirect(conn, status \\ 302, url) do
    conn
    |> Plug.Conn.put_resp_header("location", url)
    |> Plug.Conn.send_resp(status, "")
    |> Plug.Conn.halt()
  end

  @doc """
  Converts string keys in params to atoms.

  ## Parameters
    - params: A map with string keys.

  ## Examples

      changeset_params(%{"name" => "John"})
      # => %{name: "John"}
  """
  def changeset_params(params \\ %{}) do
    Enum.reduce(params, %{}, fn {k, v}, acc -> Map.put(acc, String.to_atom(k), v) end)
  end

  @doc """
  Parses errors from an Ecto changeset or a given error map/string.

  ## Parameters
    - changeset: An Ecto changeset.
    - errors: An error map or string.

  ## Examples

      parse_errors(%Ecto.Changeset{errors: [name: {"can't be blank", []}]})
      # => %{name: "can't be blank"}

      parse_errors("An error occurred")
      # => %{error: "An error occurred"}
  """
  def parse_errors(changeset = %Ecto.Changeset{}) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  def parse_errors(errors) when is_binary(errors) do
    %{error: errors}
  end

  def parse_errors(errors) when is_map(errors) do
    errors
  end

  def parse_errors(_errors) do
    %{error: "There was an error processing your request"}
  end
end

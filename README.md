# Elixir Utilities

This repository contains several utility modules for use with Elixir, particularly focused on Ecto and Plug-based applications. Below are detailed explanations and examples for each module.

## Modules

1. [Jsonb](#jsonb)
2. [Schema](#schema)
3. [Router](#router)
4. [Responses](#responses)
5. [Namespace](#namespace)
---

## Jsonb
A module for building Ecto queries with JSONB columns.

#### Example

```elixir
import Ecto.Query
query = from(p in Post)
json_query(query, :metadata, [title: "Elixir", author: "José"], where_type: :where)
# Ecto query with JSONB where clauses
```

--- 

##Schema
A module for defining common Ecto schema configurations.

#### Example

```elixir
defmodule MySchema do
  use Schema

  schema "my_table" do
    field :name, :string
    # additional fields
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name])
    |> validate_required([:name])
  end
end
```

## Router
A module for defining common Plug router configurations.

#### Example

```elixir
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
```

## Responses
A module providing wrappers for common HTTP responses in Plug applications.

#### Example

```elixir
# Sending a JSON response
conn |> json(:ok, %{hello: "World"})
conn |> json(:ok, %{hello: "World"}, resp_headers: %{"x-foo" => "bar"})

# Sending an HTML response
conn |> html(:ok, "<h1>Hello World</h1>")
conn |> html(:ok, "<h1>Hello World</h1>", resp_headers: %{"x-foo" => "bar"})

# Sending a text response
conn |> text(:ok, "Hello World!")
conn |> text(:ok, "Hello World!", resp_headers: %{"x-foo" => "bar"})

# Sending a file response
conn |> file(:ok, "/path/to/file")
conn |> file(:ok, "/path/to/file", resp_headers: %{"x-foo" => "bar"})

# Sending a file download response
conn |> download(:ok, "/path/to/file")
conn |> download(:ok, "/path/to/file", resp_headers: %{"x-foo" => "bar"})

# Sending a status-only response
conn |> status(:ok)

# Redirecting the request
conn |> redirect("http://example.com/")
conn |> redirect(301, "http://example.com/")

# Converting string keys in params to atoms
changeset_params(%{"name" => "John"})
# => %{name: "John"}

# Parsing errors from an Ecto changeset or a given error map/string
parse_errors(%Ecto.Changeset{errors: [name: {"can't be blank", []}]})
# => %{name: "can't be blank"}

parse_errors("An error occurred")
# => %{error: "An error occurred"}

```

## Namespace
Adds conditional namespacing to plug's router

#### Example

```elixir
defmodule MyApp.Router do
  use Plug.Router
  import Namespace

  plug :match
  plug :dispatch

  namespace "/user" do
    plug Plug.Logger
    plug :auth_required

    get "/" do
      send_resp(conn, 200, ~s({"message": "Welcome to Authenticated User"}))
    end
  end

  match _ do
    send_resp(conn, 404, "Oops!")
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
```

## License
This project is licensed under the MIT License.
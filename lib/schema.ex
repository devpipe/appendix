defmodule Schema do
  @moduledoc """
  A module for defining common Ecto schema configurations.

  This module provides a macro `__using__/1` to include common schema settings,
  such as primary key type, foreign key type, and necessary imports.
  """

  @doc """
  A macro to set up common configurations for Ecto schemas.

  This macro sets the primary key to use binary IDs, imports necessary Ecto modules,
  and sets the default foreign key type to binary ID.

  ## Examples

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
  """
  defmacro __using__(_) do
    quote do
      use Ecto.Schema
      import Ecto.Changeset
      import Ecto.Query

      @primary_key {:id, :binary_id, autogenerate: true}
      @foreign_key_type :binary_id
    end
  end
end

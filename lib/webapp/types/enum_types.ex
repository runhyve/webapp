defmodule Webapp.Types.EnumTypes do
  @moduledoc """
  Behaviour to represent Enum types with mapping
  """

  @callback valid_types :: [String.t()]

  defmacro __using__(_) do
    quote do
      use Ecto.Type
      @behaviour Webapp.Types.EnumTypes

      def cast(value) do
        if Enum.member?(valid_types(), value), do: {:ok, value}, else: :error
      end

      def load(value), do: {:ok, value}

      def dump(value) do
        if Enum.member?(valid_types(), value), do: {:ok, value}, else: :error
      end
    end
  end
end

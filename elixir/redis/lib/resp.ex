defmodule Resp do
  @moduledoc """
  RESP protocol serializer / deserializer.
  """

  @doc """
  Parse array of bulk strings to array of strings
  """
  def from_array_of_bulk_strings(string) do
    string
    |> String.split("\r\n")
    |> Enum.reject(&(&1 == ""))
    |> Enum.reject(&String.match?(&1, ~r/[\*|\$]\d+/))
  end

  @doc """
  Serialize string to bulk string
  """
  def bulk_string(nil), do: "$-1\r\n"

  def bulk_string(string), do: "$#{String.length(string)}\r\n#{string}\r\n"

  @doc """
  Serialize string to simple string
  """
  def simple_string(string), do: "+#{string}\r\n"
end

defmodule Workers do
  @moduledoc """
  Workers for handling client connections
  """
  require Logger

  def child_spec(opts \\ []) do
    Supervisor.child_spec({Task.Supervisor, name: __MODULE__}, opts)
  end

  def handle(client) do
    {:ok, pid} = Task.Supervisor.start_child(__MODULE__, fn -> serve(client) end)
    # Make the handler a controlling process for client so crashing the server
    # won't crash existing connections
    :ok = :gen_tcp.controlling_process(client, pid)
  end

  defp serve(client) do
    client
    |> read
    |> execute
    |> write(client)

    serve(client)
  end

  # Commands are sent as arrays of bulk strings, e.g. `*2\r\n$4PING\r\n$2\r\nME\r\n`
  defp read(socket) do
    {:ok, data} = :gen_tcp.recv(socket, 0)

    data
    |> Resp.from_array_of_bulk_strings()
    |> Enum.map(&String.downcase(&1))
  end

  defp execute(["echo", message]), do: Resp.bulk_string(message)

  defp execute(["get", key]), do: Store.get(key) |> Resp.bulk_string()

  defp execute(["ping"]), do: Resp.simple_string("PONG")

  defp execute(["ping", pong]), do: Resp.bulk_string(pong)

  defp execute(["set", key, val]) do
    Store.set(key, val)
    Resp.simple_string("OK")
  end

  defp execute(["set", key, val, "px", ms]) do
    Store.set(key, val, String.to_integer(ms))
    Resp.simple_string("OK")
  end

  defp execute(data), do: data

  defp write(data, socket), do: :gen_tcp.send(socket, data)
end

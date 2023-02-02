defmodule Server do
  @moduledoc """
  Server responsible for accepting connections
  """
  require Logger
  use Task

  def start_link(port) do
    {:ok, pid} = Task.start_link(__MODULE__, :run, [port])
    # Make the server process available under `__MODULE__` name
    Process.register(pid, __MODULE__)
    {:ok, pid}
  end

  def child_spec(port) do
    # Make sure server restarts on failure
    %{id: __MODULE__, restart: :transient, start: {Server, :start_link, [port]}}
  end

  def run(port) do
    Logger.info("Accepting connections on port #{port}")
    {:ok, socket} = :gen_tcp.listen(port, [:binary, active: false, reuseaddr: true])
    accept(socket)
  end

  defp accept(socket) do
    {:ok, client} = :gen_tcp.accept(socket)
    Workers.handle(client)
    accept(socket)
  end
end

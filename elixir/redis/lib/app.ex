defmodule App do
  @moduledoc """
  Simple implementation of a Redis server.
  """

  use Application

  @doc """
  Start application with its all components
  """
  def start(_type, _args) do
    children = [
      Store,
      Workers,
      {Server, 6379}
    ]

    opts = [name: App.Supervisor, strategy: :one_for_one]

    Supervisor.start_link(children, opts)
  end
end

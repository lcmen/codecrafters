defmodule Store do
  @moduledoc """
  Simple key / value store. It might be a bottle-neck in highly concurrent environments.
  """
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    __MODULE__
    |> Agent.get(&Map.get(&1, key))
    |> expire(key)
  end

  def set(key, value, ex \\ nil) do
    Agent.update(__MODULE__, &assign(&1, key, value, ex))
  end

  defp assign(store, key, value, nil), do: Map.put(store, key, {value, nil})

  defp assign(store, key, value, ex), do: Map.put(store, key, {value, :os.system_time(:millisecond) + ex})

  defp expire(nil, _), do: nil

  defp expire({val, ex}, key) do
    if ex && ex <= :os.system_time(:millisecond) do
      set(key, nil)
      nil
    else
      val
    end
  end
end

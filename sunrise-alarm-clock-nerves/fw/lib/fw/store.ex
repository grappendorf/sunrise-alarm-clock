defmodule Fw.Store do
  alias Fw.Store
  defstruct state: nil, reducers: [], subscribers: []

  def new(initial_state, reducers \\ [], subscribers \\ []) do
    %Store{
      state: initial_state,
      reducers: List.flatten(reducers),
      subscribers: List.flatten(subscribers)}
  end

  def state(store), do: store.state

  def reduce store, reducers do
    reducers = store.reducers |> Kernel.++([reducers]) |> List.flatten |> Enum.uniq
    %Store{store | reducers: reducers}
  end

  def subscribe store, subscribers do
    subscribers = store.subscribers |> Kernel.++([subscribers]) |> List.flatten |> Enum.uniq
    %Store{store | subscribers: subscribers}
  end

  def dispatch store, action do
    new_state = reduce_state store.reducers, store.state, action
    notify_subscribers store.subscribers, new_state, store.state
    %Store{store | state: new_state}
  end

  defp reduce_state(reducers, state, action) when is_list(reducers) do
    reducers |> Enum.reduce(state, &(reduce_state &1, &2, action))
  end

  defp reduce_state(reducer, state, action) when is_pid(reducer) do
    GenServer.call reducer, {action, state}
  end

  defp reduce_state(reducer, state, action) when is_atom(reducer) do
    apply reducer, :reduce, [state, action]
  end

  defp reduce_state(reducer, state, action) when is_function(reducer) do
    reducer.(state, action)
  end

  defp notify_subscribers(subscribers, new_state, old_state) when is_list(subscribers) do
    subscribers |> Enum.each(&(notify_subscribers(&1, new_state, old_state)))
  end

  defp notify_subscribers(subscriber, new_state, old_state) when is_pid(subscriber) do
    GenServer.call subscriber, {:update, new_state, old_state}
  end

  defp notify_subscribers(subscriber, new_state, old_state) when is_atom(subscriber) do
    apply subscriber, :update, [new_state, old_state]
  end

  defp notify_subscribers(subscriber, new_state, old_state) when is_function(subscriber) do
    subscriber.(new_state, old_state)
  end
end

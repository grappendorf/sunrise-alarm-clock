defmodule StoreHelpers do
  def update_store(store, state), do: store |> reduce_to(state) |> dispatch()
  def reduce_to(store, state), do: store |> Store.reduce(fn _, :action -> state end)
  def dispatch(store), do: store |> Store.dispatch(:action)
end

defmodule StoreHelpers do
  def update_store(store, state), do: store |> reduce_to(state) |> dispatch()
  def reduce_to(store, state), do: store |> Store.reduce(fn _, :action -> state end)
  def dispatch(store), do: store |> Store.dispatch(:action)
end

defmodule WaitHelper do
  @default_timeout 1 * 1000

  def wait_until(fun), do: wait_until @default_timeout, fun

  def wait_until(0, fun), do: fun.()

  def wait_until(timeout, fun) do
    try do
      fun.()
    rescue
      [ExUnit.AssertionError, ESpec.AssertionError] ->
        Process.sleep 10
        wait_until(max(0, timeout - 10), fun)
    end
  end

  defmacro wait_for(do: block) do
    quote do: wait_until fn -> unquote(block) end
  end
end

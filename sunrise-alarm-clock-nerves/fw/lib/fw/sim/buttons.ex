defmodule Fw.Sim.Buttons do
  use ExActor.GenServer, export: :buttons

  defstart start_link action_dispatch do
    initial_state %{
      action_dispatch: action_dispatch}
  end

  defcast press(num), state: state do
    state.action_dispatch.({:button, num})
    noreply()
  end
end

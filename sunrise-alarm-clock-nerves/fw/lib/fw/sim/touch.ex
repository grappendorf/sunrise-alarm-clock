defmodule Fw.Sim.Touch do
  use ExActor.GenServer, export: :touch

  defstart start_link action_dispatch do
    initial_state %{
      action_dispatch: action_dispatch}
  end

  defcast touch, state: state do
    state.action_dispatch.(:touch)
    noreply()
  end
end

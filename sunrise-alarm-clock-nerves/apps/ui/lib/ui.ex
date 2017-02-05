defmodule Ui do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec

    children = case Application.get_env(:fw, :misc)[:start_children] do
      true -> [
        supervisor(Ui.Endpoint, []),
      ]
      false -> []
    end

    opts = [strategy: :one_for_one, name: Ui.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    Ui.Endpoint.config_change(changed, removed)
    :ok
  end
end

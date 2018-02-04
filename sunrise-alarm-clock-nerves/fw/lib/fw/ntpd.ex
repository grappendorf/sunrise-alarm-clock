defmodule Ntpd do
  use ExActor.GenServer, export: :ntp_client
  require Logger

  @startup_delay Application.get_env(:fw, :ntpd)[:startup_delay]
  @restart_delay Application.get_env(:fw, :ntpd)[:restart_delay]
  @command Application.get_env(:fw, :ntpd)[:command]
  @servers Application.get_env(:fw, :ntpd)[:servers]

  defstart start_link do
    schedule_start @startup_delay
    initial_state %{}
  end

  defhandleinfo :start_ntpd do
    IO.inspect command()
    Port.open({:spawn, command()}, [
      :exit_status,
      :use_stdio,
      :binary,
      :stderr_to_stdout
    ])
    noreply()
  end

  defhandleinfo {_, {:exit_status, code}} do
    Logger.debug "Ntpd command exited with code: #{code}"
    schedule_start @restart_delay
    noreply()
  end

  defhandleinfo {_, {:data, data}} do
    Logger.debug "Ntpd command: #{data}"
    noreply()
  end

  defp schedule_start interval do
    Process.send_after self(), :start_ntpd, interval
  end

  defp command do
    "#{@command} -n #{servers()}"
  end

  defp servers do
    @servers |> Enum.map(& "-p #{&1}") |> Enum.join(" ")
  end
end

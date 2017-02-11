defmodule Ui.UserSocket do
  use Phoenix.Socket

  channel "client", Ui.ClientChannel

  transport :websocket, Phoenix.Transports.WebSocket
  transport :longpoll, Phoenix.Transports.LongPoll

  def connect(_params, socket) do
    Logic.subscribe &Ui.ClientChannel.publish_store_changed/2
    {:ok, socket}
  end

  def id(_socket), do: nil
end

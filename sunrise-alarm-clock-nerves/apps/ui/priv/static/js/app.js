$(function() {
  let socket = new window.Phoenix.Socket("/socket");
  socket.connect();

  window.channel = socket.channel("client");
  window.channel.join();
});

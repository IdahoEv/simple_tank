
var ExternalUX = (function () {

  var my = {},
      messages_sent = 0,
      messages_received = 0;

  my.init = function(){
    my.socket_disconnected();
    $("#connect_button").click(function(){
      SocketHandler.connect_to_game();
    });
  }

  my.socket_connected = function() {
    $('#connection').html('<span style="color: green;">CONNECTED </span>'); 
  }
  my.socket_disconnected = function() {
    $('#connection').html('<span style="color: red;">NOT CONNECTED </span>'); 
  }
  my.message_sent = function(message) {
    messages_sent++;
    displayMessage('#sent_messages', message);
    updateScreenState();
  }
  my.message_received = function(message) {
    messages_received++;
    displayMessage('#received_messages', message);
    updateScreenState();
  }
  my.error = function(event) {
    if (event.data !== undefined) {
      statusMessage("ERROR: "+ event.data);
    } else {
      statusMessage("UNKNOWN ERROR: "+ event.data);
    }
  }

  function statusMessage(message) {
    displayMessage('#status_messages', message);
  }

  function updateScreenState() {
    $('#rcvd_message_count').html(messages_received);
    $('#sent_message_count').html(messages_sent);
  }

  function formatMessage(message) {
    "<p class='message'>" + message + "</p>";
  }
  function displayMessage(destination,msg) {
    $(destination + " .message_container").prepend(formatMessage(msg));
  }

  return my
}());


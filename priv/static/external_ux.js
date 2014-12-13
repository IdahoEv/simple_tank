
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
  my.update_bullet_list = function(bullet_list) {
    $('#bullet_count').html(bullet_list.length); 
  }
  my.update_tank_state = function(tank_state) {
    $('#tank_coords').html(round(tank_state.position.x) + ", " + round(tank_state.position.y)); 
    $('#tank_speed').html(round(tank_state.speed)); 
    $('#tank_orientation').html(round(tank_state.rotation)); 
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
    return "<p class='message'>" + message + "</p>";
  }
  function displayMessage(destination,msg) {
    $(destination + " .message_container").prepend(formatMessage(msg));
  }

  function round(num) {
    return Math.round(num * 100) / 100
  }
  return my
}());


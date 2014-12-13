
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
    $('#socket_connection').html('ON'); 
  }
  my.socket_disconnected = function() {
    $('#socket_connection').html('OFF'); 
  }
  my.game_connected = function() {
    $('#game_connection').html('ON'); 
  }
  my.game_disconnected = function() {
    $('#game_connection').html('OFF'); 
  }
  my.update_bullet_list = function(bullet_list) {
    $('#bullet_count').html(bullet_list.length); 
  }
  my.update_tank_state = function(tank_state) {
    $('#tank_coords').html(my.round(tank_state.position.x) 
        + ", " 
        + my.round(tank_state.position.y)); 
    $('#tank_speed').html(my.round(tank_state.speed)); 
    $('#tank_rotation').html(my.round(tank_state.rotation)); 
    $('#tank_angular_velocity').html(my.round(tank_state.angular_velocity)); 
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
  function displayMessage(destination, msg, limit) {
    if (typeof limit === 'undefined' ){
      limit = 60;
    }
    $(destination + " .message_container").prepend(formatMessage(msg));
    $(destination + " .message_container .message").slice(limit).remove();
  }

  my.round = function(num) {
    return Math.round(num * 100) / 100
  }
  return my
}());


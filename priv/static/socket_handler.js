var SocketHandler = (function(){
  var my = {},
    websocket,
    wsHost = '';

  my.init = function() {
    wsHost = "ws://" + window.location.host + "/websocket";
    ExternalUX.socket_disconnected();
    ExternalUX.game_disconnected();
    if(!("WebSocket" in window)){  
      $('#connection').html('<span style="color: red;">websockets are not supported </span>');
    } else {
      connect();
    } 
  };
  my.transmit = function(object) {
    sendJSON(object);
  }
  my.connect_to_game = function() {   
    console.log("attempting connection, readyState is ", websocket.readyState, websocket.OPEN);
    if(!websocket.readyState == websocket.OPEN) {
      connect();
    }
    message = { 
      connect: 'new',
      name: $('#player_name').val()
    }
    sendJSON(message);    
  };

  // Private methods
  function connect() {
    if (websocket == undefined || !(websocket.readyState == websocket.OPEN)) {
      websocket = new WebSocket(wsHost);
      websocket.onopen = function(evt) { onOpen(evt) }; 
      websocket.onclose = function(evt) { onClose(evt) }; 
      websocket.onmessage = function(evt) { onMessage(evt) }; 
      websocket.onerror = function(evt) { onError(evt) }; 
    }
  };  

  function disconnect() {
    websocket.close();
  }; 

  function toggle_connection(){
    if(websocket.readyState == websocket.OPEN){
      disconnect();
    } else {
      connect();
    };
  };

  function sendJSON(message) {
    if(websocket.readyState == websocket.OPEN){
      string_message = JSON.stringify(message);
      websocket.send(string_message);
      ExternalUX.message_sent(string_message);
    } else {
      ExternalUX.socket_disconnected();
    };
  };

  function onOpen(evt) { 
    ExternalUX.socket_connected();
  };  

  function onClose(evt) { 
    ExternalUX.socket_disconnected();
  };  

  function onMessage(evt) { 
    message = JSON.parse(evt.data);
    ExternalUX.message_received(evt.data);
    if (message.private_id !== undefined) {
      // TODO save player id
      ExternalUX.game_connected();
    }
    if ( message.state_update !== undefined) {
      GameWindow.updateWorld(message.state_update);
      ExternalUX.updateWorld(message.state_update);
    }
  };  

  function onError(evt) {
    ExternalUX.error(evt);
  };


  function clearScreen() 
  { 
    $('#output').html("");
  };

  return my;
}());


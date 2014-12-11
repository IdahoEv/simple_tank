var SocketHandler = (function(){
  var my = {},
    websocket,
    messages = 0,
    moveScale = 0.5,
    wsHost = '';

  my.init = function() {
    wsHost = "ws://" + window.location.host + "/websocket";
    if(!("WebSocket" in window)){  
      $('#status').append('<p><span style="color: red;">websockets are not supported </span></p>');
      $("#navigation").hide();  
    } else {
      //$('#status').append('<p><span style="color: green;">websockets are supported </span></p>');
      connect();
    };
  };
  my.transmit = function(object) {
    sendJSON(object);
  }
  my.connect_to_game = function() {   
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
    //wsHost = $("#server").val()
    websocket = new WebSocket(wsHost);
    websocket.onopen = function(evt) { onOpen(evt) }; 
    websocket.onclose = function(evt) { onClose(evt) }; 
    websocket.onmessage = function(evt) { onMessage(evt) }; 
    websocket.onerror = function(evt) { onError(evt) }; 
    ExternalUX.socket_connected();
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
      ExternalUX.message_sent(message);
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

  function updateTankState(tank_state) {  
    var x = tank_state.position.x;
    var y = tank_state.position.y;
    $('#position').html( "(" + Number(x.toFixed(2)) +", " + Number(y.toFixed(2)) +") "
        + " speed: " + Number(tank_state.speed.toFixed(3)) 
        + " rotation: " + Number(tank_state.rotation.toFixed(2))
        );
    //console.log("Drawing tank at: "+x+ ", "+y);
    GameWindow.update_tank(tank_state);
    messages++;
    $('#message_count').html(messages);
  }
  function updateBulletList(bullet_list) {
    GameWindow.update_bullet_list(bullet_list);
  }

  function onMessage(evt) { 
    //console.log(evt.data);
    //try {
      message = JSON.parse(evt.data);
      ExternalUX.message_received(evt.data);
      if ( message.player_tank_physics !== undefined) {
        updateTankState(message["player_tank_physics"]);
        updateBulletList(message["bullet_list"]);
      }
      //else {
        //showScreen('<span style="color: blue;">RESPONSE: ' + evt.data+ '</span>'); 
      //}
    //} catch(err) {
      //console.log(err); 
      //console.log("Could not JSON parse event message: "+evt.data)
    //}
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


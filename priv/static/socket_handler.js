var SocketHandler = (function(){
  var my = {},
    websocket,
    messages = 0,
    moveScale = 0.5;

  my.init = function() {
    $('#server').val("ws://" + window.location.host + "/websocket");
    if(!("WebSocket" in window)){  
      $('#status').append('<p><span style="color: red;">websockets are not supported </span></p>');
      $("#navigation").hide();  
    } else {
      //$('#status').append('<p><span style="color: green;">websockets are supported </span></p>');
      connect();
    };
    $("#connected").hide(); 	
    $("#messages").hide(); 	
  };
  my.transmit = function(object) {
    sendJSON(object);
  }

  // Private methods
  function connect() {
    wsHost = $("#server").val()
    websocket = new WebSocket(wsHost);
    showScreen('<b>Connecting to: ' +  wsHost + '</b>'); 
    websocket.onopen = function(evt) { onOpen(evt) }; 
    websocket.onclose = function(evt) { onClose(evt) }; 
    websocket.onmessage = function(evt) { onMessage(evt) }; 
    websocket.onerror = function(evt) { onError(evt) }; 
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
      showScreen('sending: ' + string_message); 
    } else {
      showScreen('websocket is not connected'); 
    };
  };

  function onOpen(evt) { 
    showScreen('<span style="color: green;">CONNECTED </span>'); 
    $("#connected").fadeIn('slow');
    $("#messages").fadeIn('slow');
  };  

  function onClose(evt) { 
    showScreen('<span style="color: red;">DISCONNECTED </span>');
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

  function onMessage(evt) { 
    //console.log(evt.data);
    //try {
      message = JSON.parse(evt.data);
      if ( message.position !== undefined) {
        updateTankState(message);
      }
      else {
        showScreen('<span style="color: blue;">RESPONSE: ' + evt.data+ '</span>'); 
      }
    //} catch(err) {
      //console.log(err); 
      //console.log("Could not JSON parse event message: "+evt.data)
    //}
  };  

  function onError(evt) {
    if (evt.data !== undefined) {
      showScreen('<span style="color: red;">ERROR: ' + evt.data + '</span>');
    } else {
      showScreen('<span style="color: red;">UNKNOWN ERROR: ' + evt + '</span>');
    }

  };

  function showScreen(txt) { 
    $('#output').prepend('<p>' + txt + '</p>');
  };

  function clearScreen() 
  { 
    $('#output').html("");
  };

  return my;
}());


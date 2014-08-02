var SocketHandler = (function(){
  var my = {},
    websocket,
    messages = 0,
    gameWindow,
    moveScale = 0.5;

  my.init = function(gw) {
    $('#server').val("ws://" + window.location.host + "/websocket");
    if(!("WebSocket" in window)){  
      $('#status').append('<p><span style="color: red;">websockets are not supported </span></p>');
      $("#navigation").hide();  
    } else {
      //$('#status').append('<p><span style="color: green;">websockets are supported </span></p>');
      connect();
      gameWindow = gw; 
    };
    $("#connected").hide(); 	
    $("#messages").hide(); 	
  };

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

  function sendDir(message) {
    if(websocket.readyState == websocket.OPEN){
      websocket.send(JSON.stringify(message));
      showScreen('sending: (' + message.x + ', ' + message.y + ')'); 
    } else {
      showScreen('websocket is not connected'); 
    };
  };
  my.sendUp = function() {
    sendDir({ x: 0, y: -1 * moveScale})
  };
  my.sendDown = function() {
    sendDir({ x: 0, y: moveScale})
  };
  my.sendLeft = function() {
    sendDir({ x: -1 * moveScale, y: 0})
  };
  my.sendRight = function() {
    sendDir({ x: moveScale, y: 0})
  };

  function onOpen(evt) { 
    showScreen('<span style="color: green;">CONNECTED </span>'); 
    $("#connected").fadeIn('slow');
    $("#messages").fadeIn('slow');
  };  

  function onClose(evt) { 
    showScreen('<span style="color: red;">DISCONNECTED </span>');
  };  

  function updatePosition(position) {
    var x = message.position.x;
    var y = message.position.y;
    $('#position').html( Number(x.toFixed(2)) +", " + Number(y.toFixed(2)) );
    console.log("Drawing tank at: "+x+ ", "+y);
    GameWindow.draw({x: x, y: y});
    messages++;
    $('#message_count').html(messages);
  }

  function onMessage(evt) { 
    //console.log(evt.data);
    try {
      message = JSON.parse(evt.data);
      if ( message.position !== undefined) {
        updatePosition(message.position);
      }
      else {
        showScreen('<span style="color: blue;">RESPONSE: ' + evt.data+ '</span>'); 
      }
    } catch(err) {
      console.log(err);
      //console.log("Could not JSON parse event message: "+evt.data)
    }
  };  

  function onError(evt) {
    showScreen('<span style="color: red;">ERROR: ' + evt.data+ '</span>');
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

$(document).ready(function(){
  var gw = GameWindow.init();
  SocketHandler.init(gw);
});

var websocket;
var frames = 0;
var messages = 0;
$(document).ready(init);

function init() {
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

function connect()
{
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
        function sendUp() {
          sendDir({ x: 0, y: -0.1})
        };
        function sendDown() {
          sendDir({ x: 0, y: 0.1})
        };
        function sendLeft() {
          sendDir({ x: -0.1, y: 0})
        };
        function sendRight() {
          sendDir({ x: 0.1, y: 0})
        };

        function onOpen(evt) { 
          showScreen('<span style="color: green;">CONNECTED </span>'); 
          $("#connected").fadeIn('slow');
          $("#messages").fadeIn('slow');
        };  

function onClose(evt) { 
  showScreen('<span style="color: red;">DISCONNECTED </span>');
};  

function onMessage(evt) { 
  console.log(evt.data);
  message = JSON.parse(evt.data);
  if ( message.position !== undefined) {
    $('#position').html(Number(message.position.x.toFixed(2)) +
        ", " + 
        Number(message.position.y.toFixed(2)));
    messages++;
    console.log(messages);
    $('#message_count').html(messages);
  }
  else {
    showScreen('<span style="color: blue;">RESPONSE: ' + evt.data+ '</span>'); 
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


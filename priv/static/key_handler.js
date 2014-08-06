var KeyHandler = (function(){
  var my = {},
    canvas;

  my.init = function(){
    canvas = GameWindow.canvas;
    canvas.addEventListener('keydown', keydown);
    canvas.addEventListener('keyup', keyup);   
  }

  function keydown(event){
    console.log("Keydown"+event.keyIdentifier); 
    switch(event.keyIdentifier) {
      //case "Right":   SocketHandler.sendTurn("right");      break;
      //case "Left":    SocketHandler.sendTurn("left");       break;
      case "Up":      transmit("acceleration","forward",event);   break;
      case "Down":    transmit("acceleration","reverse",event);   break;
      default: console.log("Keydown"+event.keyIdentifier); 
    }
  }
  function keyup(event){
    console.log("Keyup"+event.keyIdentifier); 
    switch(event.keyIdentifier) {
      case "Up":        transmit("acceleration","off", event);   break;
      case "Down":      transmit("acceleration","off", event);   break;
      default: console.log("Keyup"+event.keyIdentifier); 
    }
  }
  function transmit(type, command, event) {
    SocketHandler.transmit(type, command);
    event.preventDefault();
  }

  return my;
}());

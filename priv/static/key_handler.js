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
      case "Up":      SocketHandler.sendAccel("forward");   break;
      case "Down":    SocketHandler.sendAccel("reverse");   break;
      default: console.log("Keydown"+event.keyIdentifier); 
    }
    event.preventDefault();    
  }
  function keyup(event){
    console.log("Keyup"+event.keyIdentifier); 
    switch(event.keyIdentifier) {
      case "Up":        SocketHandler.sendAccel("off");   break;
      case "Down":      SocketHandler.sendAccel("off");   break;
      default: console.log("Keyup"+event.keyIdentifier); 
    }
    event.preventDefault();    
  }

  return my;
}());

var KeyHandler = (function(){
  var my = {},
    canvas;

  my.init = function(){
    canvas = GameWindow.canvas;
    canvas.addEventListener('keydown', keydown);
    canvas.addEventListener('keyup', keydown);   
  }

  function keydown(event){
    switch(event.keyIdentifier) {
      case "Right":   SocketHandler.sendRight();  break;
      case "Left":    SocketHandler.sendLeft();   break;
      case "Up":      SocketHandler.sendUp();     break;
      case "Down":    SocketHandler.sendDown();   break;
    }
    event.preventDefault();    
  }
  function keyup(event){
    console.log("Keyup"+event); 
  }

  return my;
}());

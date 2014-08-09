var KeyHandler = (function(){
  var my = {},
    control_state; 

  my.init = function(){
    control_state = { acceleration: 'off', rotation: 'off' };
  }

  my.keyUpUp      = function() { updateState("acceleration", "off") } 
  my.keyUpDown    = function() { updateState("acceleration", "forward") } 
  my.keyDownUp    = function() { updateState("acceleration", "off") } 
  my.keyDownDown  = function() { updateState("acceleration", "reverse") } 
  my.keyLeftUp    = function() { updateState("rotation", "off") } 
  my.keyLeftDown  = function() { updateState("rotation", "left") } 
  my.keyRightUp   = function() { updateState("rotation", "off") } 
  my.keyRightDown = function() { updateState("rotation", "right") } 
  
  function updateState(control, state) { 
    console.log('updateState called')
    if (control_state[control] != state) {
      control_state[control] = state;
      transmit();
    }
  }

  function transmit() {
    SocketHandler.transmit(control_state);
  }

  return my;
}());

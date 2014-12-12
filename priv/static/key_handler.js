var KeyHandler = (function(){
  var my = {},
    control_state,
    timeout_loop; 

  my.init = function(){
    control_state = { acceleration: 'off', rotation: 'off', trigger: 'off' };
  }

  my.keyUpUp      = function() { updateState("acceleration", "off") } 
  my.keyUpDown    = function() { updateState("acceleration", "forward") } 
  my.keyDownUp    = function() { updateState("acceleration", "off") } 
  my.keyDownDown  = function() { updateState("acceleration", "reverse") } 
  my.keyLeftUp    = function() { updateState("rotation", "off") } 
  my.keyLeftDown  = function() { updateState("rotation", "left") } 
  my.keyRightUp   = function() { updateState("rotation", "off") } 
  my.keyRightDown = function() { updateState("rotation", "right") } 
  my.keyFireUp    = function() { updateState("trigger", "off") } 
  my.keyFireDown  = function() { updateState("trigger", "on") } 
  
  function updateState(control, state) { 
    console.log('updateState called')
    if (control_state[control] != state) {
      control_state[control] = state;
      transmit();
    }
  }

  function transmit() {
    SocketHandler.transmit({ controls: control_state});

    // every 600ms, re-transmit state to the server to prevent unintentional decay
    clearTimeout(timeout_loop);
    timeout_loop = setTimeout(function() { transmit() }, 600);
  }

  return my;
}());

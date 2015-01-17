var KeyHandler = (function(){
  var my = {},
    control_state,
    timeout_loop;

  my.init = function(sound_effects){
    control_state = { acceleration: 'off', rotation: 'off', trigger: 'off' };
  }

  my.keyUpUp      = function() { updateState("acceleration", "off") } 
  my.keyUpDown    = function() { updateState("acceleration", "forward") } 
  my.keyDownUp    = function() { updateState("acceleration", "off") } 
  my.keyDownDown  = function() { updateState("acceleration", "reverse") } 
  my.keyFireUp    = function() { updateState("trigger", "off") } 
  my.keyFireDown  = function() { updateState("trigger", "on") } 
  my.keyLeftUp    = function() { updateState("rotation", "off") } 
  my.keyLeftDown  = function() { updateState("rotation", "left") } 
  my.keyRightUp   = function() { updateState("rotation", "off") } 
  my.keyRightDown = function() { updateState("rotation", "right") } 
  
  function updateState(control, state) { 
    //console.log('updateState called');
    if (control_state[control] != state) {
      control_state[control] = state;
      if (control == 'trigger' && state == 'on'){
        GameWindow.playShotSound();
      }
      transmit();
    }
    if (control == "rotation") { GameWindow.update_UI_steering(state) }    
  }

  function transmit() {
    SocketHandler.transmit({ controls: control_state});

    // every 600ms, re-transmit state to the server to prevent unintentional decay
    clearTimeout(timeout_loop);
    timeout_loop = setTimeout(function() { transmit() }, 600);
  }

  return my;
}());

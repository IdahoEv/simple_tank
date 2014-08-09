
$(document).ready(function(){
  KeyHandler.init();
  GameWindow.init(KeyHandler);
  SocketHandler.init();
  $('#gameCanvas').focus();
});

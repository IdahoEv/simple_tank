
$(document).ready(function(){
  ExternalUX.init();
  KeyHandler.init();
  GameWindow.init(KeyHandler);
  SocketHandler.init();
  $('#gameCanvas').focus();
});

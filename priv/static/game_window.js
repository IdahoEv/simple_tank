var GameWindow = (function () {
  var my = {},
    canvas,
    context,
    width,
    height,
    scale = 16,   // pixels per unit size. Tank height/width is 1.0 unit size.
    tankImage;

  var imageObj = new Image();


  function drawField() {
    context.beginPath();
    context.rect(width / -2, height / -2, width, height);
    context.fillStyle = '#99CA99';
    context.fill();
  }

  function scaleCoords(coords){
    return { 
      x: (coords.x * scale),
      y: (coords.y * scale)
    }
  }

  my.init = function() {
    canvas = document.getElementById('gameCanvas');
    context = canvas.getContext('2d');
    my.canvas = canvas;
    width = canvas.width;
    height = canvas.height;
    context.translate( (width / 2.0), (height / 2.0) );
    tankImage = new Image();
    tankImage.src = '/static/images/tank.png';
  }
  
  my.draw = function(tank){
    drawField();
    tankCoords = scaleCoords(tank);
    context.drawImage(tankImage, tankCoords.x - scale/2, tankCoords.y - scale/2);
    //context.beginPath();
    //context.rect( scale, scale);
    //context.fillStyle = 'black';
    //context.fill();
  }

	return my;
}());

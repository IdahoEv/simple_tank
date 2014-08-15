var GameWindow = (function () {


  var my = {},
    game,
    key_handler,
    tank_state,
    sprite,
    default_width = 500,
    default_height = 500,
    scale = 32;   // pixels per unit size. Tank height/width is 1.0 unit size.

  var imageObj = new Image();

  function preload() {
    game.load.image('tank', '/static/images/tank-32.png');
  }
 
  function create() {
    //game.world.scale = new Phaser.Point(0.5,0.5);
    
    game.stage.backgroundColor = "90fa60";
    //game.physics.startSystem(Phaser.Physics.ARCADE);
    sprite = game.add.sprite(game.world.centerX, game.world.centerY, 'tank');

    sprite.anchor.setTo('0.5', '0.5');
    //game.physics.enable(sprite, Phaser.Physics.ARCADE);
    //sprite.body.allowRotation = false;

    keys = [[ "UP",    KeyHandler.keyUpDown,    KeyHandler.keyUpUp ],
            [ "DOWN",  KeyHandler.keyDownDown,  KeyHandler.keyDownUp ],
            [ "LEFT",  KeyHandler.keyLeftDown,  KeyHandler.keyLeftUp ],
            [ "RIGHT", KeyHandler.keyRightDown, KeyHandler.keyRightUp ],
            [ "SPACEBAR", KeyHandler.keyFireDown,  KeyHandler.keyFireUp ]
            ]

    for (i=0; i < keys.length; i++ ) {
      key = game.input.keyboard.addKey(Phaser.Keyboard[keys[i][0]]);
      key.onDown.add(keys[i][1]);
      key.onUp.add(keys[i][2]);
    }
  }


  function update() {
    console.log("Tank position: "+ tank_state.position.x + ", " + tank_state.position.y)
    sprite.x = game.world.centerX + (scale*tank_state.position.x);
    sprite.y = game.world.centerY + (scale*tank_state.position.y);
    sprite.angle = tank_state.rotation * 360 / (2 * Math.PI) + 90;
  }

  my.init = function(kh) {
    key_handler = kh;
    tank_state = { position: { x: 0, y: 0},
             speed: 0,
             orientation: Math.PI / 2.0
           } 

    game = new Phaser.Game(default_width, default_height, Phaser.AUTO, 'gameField', 
        { preload: preload, 
          create: create,
          update: update });

  }

  my.update_tank = function(new_tank_state) {
    tank_state = new_tank_state;
  }
  
  
  return my;
}());

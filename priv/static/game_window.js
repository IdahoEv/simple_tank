var GameWindow = (function () {

  var my = {},
    game,
    key_handler,
    tank_state = {},
    bullet_list = [],
    bullet_sprites = {},
    sprite,
    default_width = 600,
    default_height = 600,
    scale = 32;   // pixels per unit size. Tank height/width is 1.0 unit size.

  var imageObj = new Image();

  function preload() {
    game.load.image('tank', '/static/images/tank-32.png');
    game.load.image('shell', '/static/images/shell-32.png');
  }
 
  function create() {
    //game.world.scale = new Phaser.Point(0.5,0.5);
    
    game.stage.backgroundColor = "90fa60";
    //game.physics.startSystem(Phaser.Physics.ARCADE);
    sprite = game.add.sprite(game.world.centerX, game.world.centerY, 'tank');
    //game.physics.

    sprite.anchor.setTo('0.5', '0.5');
    //game.physics.enable(sprite, Phaser.Physics.ARCADE);
    //sprite.body.allowRotation = false;

    keys = [[ "UP",    KeyHandler.keyUpDown,    KeyHandler.keyUpUp ],
            [ "DOWN",  KeyHandler.keyDownDown,  KeyHandler.keyDownUp ],
            [ "LEFT",  KeyHandler.keyLeftDown,  KeyHandler.keyLeftUp ],
            [ "RIGHT", KeyHandler.keyRightDown, KeyHandler.keyRightUp ],
            [ "SPACEBAR", KeyHandler.keyFireDown,  KeyHandler.keyFireUp ]
            ]

    for (var i=0; i < keys.length; i++ ) {
      key = game.input.keyboard.addKey(Phaser.Keyboard[keys[i][0]]);
      key.onDown.add(keys[i][1]);
      key.onUp.add(keys[i][2]);
    }
    //for (var bn = 0; bn < 31; bn ++) {
      //bullet_sprites[bn] =  game.add.sprite(game.world.centerX, game.world.centerY, 'shell');
      //bullet_sprites[bn].anchor.setTo('0.5', '0.5');
    //}
  }

  function makeBulletSprite(bullet) {
    var bullet_sprite = game.add.sprite(game.world.centerX, game.world.centerY, 'shell');
    bullet_sprite.anchor.setTo('0.5', '0.5')
    setBulletPosition(bullet_sprite, bullet);
    bullet_sprite.angle = bullet.angle * 360 / (2 * Math.PI) + 90;
    bullet_sprites[bullet.id] = bullet_sprite
  }


  function setBulletPosition(sprite, bullet) {
    sprite.x =  game.world.centerX + (scale*bullet.position.x);
    sprite.y =  game.world.centerY + (scale*bullet.position.y);
  }

   

  function updateBullets() {
    //console.log("Total bullets/sprites: "+bullet_list.length);
    //console.log(bullet_sprites);
        //+ "/" + bullet_sprites.length);
    var existing_sprite_ids = Object.keys(bullet_sprites);
    var bullet_sprite;

    // Make sure all listed bullets are updated or created
    for (var bn = 0; bn < bullet_list.length; bn++) {
      var bullet = bullet_list[bn];

      // if the sprites array already contains this bullet, update it
      if (existing_sprite_ids.indexOf(bullet.id.toString()) > -1) {
        console.log('updating existing sprite');
        bullet_sprite = bullet_sprites[bullet.id];
        setBulletPosition(bullet_sprite, bullet);
        existing_sprite_ids.splice(
          existing_sprite_ids.indexOf(bullet.id.toString()),1
        )
      // otherwise make a new sprite  
      } else { 
        console.log('creating new sprite');
        makeBulletSprite(bullet); 
      }
    }

    // remove any bullet sprites that do not exist in the server update
    for (var sin = 0; sin < existing_sprite_ids.length; sin++) {

      sid = existing_sprite_ids[sin];
      console.log('deleting sprite with id '+ sid);
      bullet_sprite = bullet_sprites[sid];
      bullet_sprite.kill;
      bullet_sprite.parent.removeChild(bullet_sprite);
      delete bullet_sprites[sid];
    }
  }

  function update() {
    //console.log("Tank position: "+ tank_state.position.x + ", " + tank_state.position.y)
    sprite.x = game.world.centerX + (scale*tank_state.position.x);
    sprite.y = game.world.centerY + (scale*tank_state.position.y);
    sprite.angle = tank_state.rotation * 360 / (2 * Math.PI) + 90;
    updateBullets();
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

  my.update_tank_state = function(new_tank_state) {
    tank_state = new_tank_state;
  }
  
  my.update_bullet_list = function(new_bullet_list) {
    bullet_list = new_bullet_list;
  }
  
  return my;
}());

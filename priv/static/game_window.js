var GameWindow = (function () {

  var my = {},
    game,
    key_handler,
    tank_state = {},
    bullet_list = [],
    bullet_sprites = {},
    tank,
    default_width = 600,
    default_height = 600,
    scale = 32;   // pixels per unit size. Tank height/width is 1.0 unit size.

  var imageObj = new Image();

  function preload() {
    game.load.image('tank', '/static/images/tank-32.png');
    game.load.image('shell', '/static/images/shell-32.png');
  }
 
  function create() {
    game.stage.backgroundColor = "90fa60";
    game.physics.startSystem(Phaser.Physics.ARCADE);

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
  }


  function makeBulletSprite(bullet) {
    console.log("Building bullet", bullet)
    coords = worldPoint2ScreenCoords(bullet.position);
    var bullet_sprite = game.add.sprite(coords.x, coords.y, 'shell');
    game.physics.enable(bullet_sprite, Phaser.Physics.ARCADE);
    bullet_sprite.anchor.setTo('0.5', '0.5')
    updatePhysicsFromState(bullet_sprite, bullet);
    bullet_sprites[bullet.id] = bullet_sprite
  }
  function makePlayerTankSprite() {
    my.tank = game.add.sprite(game.world.centerX, game.world.centerY, 'tank');
    game.physics.enable(my.tank, Phaser.Physics.ARCADE);
    my.tank.anchor.setTo('0.5', '0.5');
  }

  function updateBullets() {
    var existing_sprite_ids = Object.keys(bullet_sprites);
    var bullet_sprite;

    // Make sure all listed bullets are updated or created
    for (var bn = 0; bn < bullet_list.length; bn++) {
      var bullet = bullet_list[bn];

      // if the sprites array already contains this bullet, update it
      if (existing_sprite_ids.indexOf(bullet.id.toString()) > -1) {

        bullet_sprite = bullet_sprites[bullet.id];
        updatePhysicsFromState(bullet_sprite, bullet);
        //debugSpriteState (bullet_sprite, "bullet_sprite_"+bullet.id);
        //debugPhysicsState(bullet,        "bullet_state_"+bullet.id);
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

  function coordPairString(coords) {
    return "(" 
      + ExternalUX.round(coords.x) 
      + ", " 
      + ExternalUX.round(coords.y) 
      + ")"
  }

  function update() {
    //tankStateDebug();
  }

  function tankStateDebug(physics_state) {
    if(my.tank != undefined) {
      game.debug.spriteInfo(my.tank,20,20);
      debugSpriteState(my.tank, 'tank sprite');
      debugPhysicsState(physics_state, 'tank physics');
    }
  }
  function debugSpriteState(sprite, id) {
    if (typeof id == undefined) { id = 'N/A' }
    console.log(id, {
      rotation: ExternalUX.round(sprite.body.rotation),
      angle: ExternalUX.round(sprite.body.angle),
      angular_velocity:  ExternalUX.round(sprite.body.angularVelocity),
      sprite_position: coordPairString(sprite),
      body_position: coordPairString(sprite.body),
      body_velocity: coordPairString(sprite.body.velocity)
    });
  }
  function debugPhysicsState(physics, id) {
    if (typeof id == undefined) { id = 'N/A' }
    console.log(id, physics);
  }


  function worldPoint2ScreenCoords(pointObj){
    return worldCoords2ScreenCoords(pointObj.x, pointObj.y);
  } 
  function worldCoords2ScreenCoords(worldX, worldY){
    return({ x: game.world.centerX + (scale*worldX),
             y: game.world.centerY + (scale*worldY) 
           });
  }
  function world2ScreenAngVel(angular_velocity) {
    return(angular_velocity * -180 / Math.PI);
  }

  function updatePhysicsFromState(the_sprite, state) {
    coords = worldPoint2ScreenCoords(state.position);
    the_sprite.body.reset( coords.x, coords.y) ;
    the_sprite.body.rotation = state.rotation;
    the_sprite.rotation = state.rotation;
    the_sprite.body.angularVelocity = world2ScreenAngVel(state.angular_velocity); 
    game.physics.arcade.velocityFromRotation(
        the_sprite.rotation, 
        state.speed * scale,
        the_sprite.body.velocity
     );
  }

  my.init = function(kh) {
    key_handler = kh;

    game = new Phaser.Game(default_width, default_height, Phaser.AUTO, 'gameField', 
        { preload: preload, 
          create: create,
          update: update });
  }

  my.update_tank_state = function(tank_state) {
    if (my.tank == undefined) {
      makePlayerTankSprite();
    }
    updatePhysicsFromState(my.tank, tank_state);
    //tankStateDebug(tank_state);
  }

  // A cheat to improve the smoothness of apparent steering, remove the
  // "drifty" effect of server lag.
  my.update_UI_steering = function(direction) {
    if (my.tank == undefined) {
      if (direction == 'left') {
        my.tank.body.angularVelocity = tank_state.angular_velocity * -360 / Math.PI ;
      } else if (direction == 'right') {
        my.tank.body.angularVelocity = tank_state.angular_velocity * 360 / Math.PI ;
      } else {
        my.tank.body.angularVelocity = 0.0
      }   
    }   
  }


  
  
  my.update_bullet_list = function(new_bullet_list) {
    bullet_list = new_bullet_list;
    updateBullets();
  }
  
  return my;
}());

var GameWindow = (function () {

  var my = {},
    game,
    key_handler,
    tank_state = {},
    bullet_sprites = {},
    tank_sprites = {},
    tank,
    default_width = 600,
    default_height = 600,
    scale = 32;   // pixels per unit size. Tank height/width is 1.0 unit size.

  var imageObj = new Image();

  Array.prototype.diff = function(a) {
      return this.filter(function(i) {return a.indexOf(i) < 0;});
  };

  function intersect(a, b) {
    var t;
    if (b.length > a.length) t = b, b = a, a = t; // indexOf to loop over shorter
    return a.filter(function (e) {
        if (b.indexOf(e) !== -1) return true;
    });
  }

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


  function makeSpriteFromState(sprite_list, id, state, sprite_name) {
    coords = worldPoint2ScreenCoords(state.position);
    var new_sprite = game.add.sprite(coords.x, coords.y, sprite_name);
    game.physics.enable(new_sprite, Phaser.Physics.ARCADE);
    new_sprite.anchor.setTo('0.5', '0.5');
    updateSpriteState(new_sprite, state);
    sprite_list[id] = new_sprite;
  }
  function newTankSprite(tank_id, tank_state) {
    makeSpriteFromState( tank_sprites, tank_id, tank_state, 'tank');
  }
  function newBulletSprite(bullet_id, bullet_state) {
    console.log ("Making sprite from id", bullet_id);
    makeSpriteFromState( bullet_sprites, bullet_id, bullet_state, 'shell');
  }
  function makePlayerTankSprite() {
    my.tank = game.add.sprite(game.world.centerX, game.world.centerY, 'tank');
    game.physics.enable(my.tank, Phaser.Physics.ARCADE);
    my.tank.anchor.setTo('0.5', '0.5');
  }

  function updateAndFilter(sprites, updates, newSpriteFunction) {
    var sprite_ids  = Object.keys(sprites);
    var update_ids  = Object.keys(updates);
    var common_ids  = intersect(sprite_ids, update_ids);
    var new_ids     = update_ids.diff(common_ids);
    var deleted_ids = sprite_ids.diff(common_ids);

    // delete any sprites not present in the update list
    deleted_ids.forEach(function(sid) { removeSprite(sprites, sid) });
   
    // update all surviving sprites
    common_ids.forEach(function(sid) { updateSpriteState(sprites[sid], updates[sid]) });

    // create a sprite for each new one
    new_ids.forEach(function(uid){ newSpriteFunction(uid, updates[uid])});
  }

  // Given a JSON update with physics information, force the sprite to match
  // that new state
  function updateSpriteState(the_sprite, state) {
    var coords = worldPoint2ScreenCoords(state.position);
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

  // Remove a sprite both from Phaser's world and from the sprite list 
  function removeSprite(sprite_list, sprite_id) {
    var sprite = sprite_list[sprite_id];
    sprite.kill;
    sprite.parent.removeChild(sprite);
    delete sprite_list[sprite_id];
  }

  //function updateBullets() {
    //var existing_sprite_ids = Object.keys(bullet_sprites);
    //var bullet_sprite;

    //// Make sure all listed bullets are updated or created
    //for (var bn = 0; bn < bullet_list.length; bn++) {
      //var bullet = bullet_list[bn];

      //// if the sprites array already contains this bullet, update it
      //if (existing_sprite_ids.indexOf(bullet.id.toString()) > -1) {

        //bullet_sprite = bullet_sprites[bullet.id];
        //updatePhysicsFromState(bullet_sprite, bullet);
        ////debugSpriteState (bullet_sprite, "bullet_sprite_"+bullet.id);
        ////debugPhysicsState(bullet,        "bullet_state_"+bullet.id);
        //existing_sprite_ids.splice(
          //existing_sprite_ids.indexOf(bullet.id.toString()),1
        //)
      //// otherwise make a new sprite  
      //} else { 
        //console.log('creating new sprite');
        //makeBulletSprite(bullet); 
      //}
    //}

    //// remove any bullet sprites that do not exist in the server update
    //for (var sin = 0; sin < existing_sprite_ids.length; sin++) {

      //sid = existing_sprite_ids[sin];
      //console.log('deleting sprite with id '+ sid);
      //bullet_sprite = bullet_sprites[sid];
      //bullet_sprite.kill;
      //bullet_sprite.parent.removeChild(bullet_sprite);
      //delete bullet_sprites[sid];
    //}
  //}

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

  my.init = function(kh) {
    key_handler = kh;

    game = new Phaser.Game(default_width, default_height, Phaser.AUTO, 'gameField', 
        { preload: preload, 
          create: create,
          update: update });
  }

  my.updateWorld = function(world_state) {
    if (my.tank == undefined) {
      makePlayerTankSprite(world_state.player_tank);
    }
    var player_public_id = world_state.player_tank.id;

    updateSpriteState(my.tank, world_state.player_tank);
    updateAndFilter(bullet_sprites, world_state.bullets, newBulletSprite);
    delete world_state.tanks[player_public_id];  // don't show self tank in other sprites list
    updateAndFilter(tank_sprites,   world_state.tanks, newTankSprite);   
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

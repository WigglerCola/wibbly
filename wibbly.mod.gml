#define init
    trace("WIBBLY 0.2.5 LOADED!!");
    // WIGGLERCOLA ULTIMATE SHARED FUNCTION LIBRARY!!!!!!!! //
    /*
        CURRENT FEATURES
        BONUS MAX AMMO APPLIES CORRECTLY WHEN BACK MUSCLE CHANGES
        STAT BONUSES APPLY CORRECTLY ON RESPAWN (Max Ammo, Ammo Gain, Max Speed, Reload Speed, Accuracy)
        PROJECTILE SPEED BONUS HANDLER
        RAD MAX BONUS HANDLER
        
        
    	ammoMaxBonus_add(_index, _ammoType, _count);
    	ammoGainBonus_add(_index, _ammoType, _count);
    	speedBonus_add(_index, _speed);
    	reloadBonus_add(_index, _bonus);
    	accuracyBonus_add(_index, _bonus);				// stops at 0. might cause problems, look into it
    	projectileSpeedBonus_add(_index, _bonus);
    	radMaxBonus_add(_bonus);						// waits until level ultra to apply changes 
    	
    	
    		'raw' versions of stat increases that dont apply stats to the player
    		trinkets use these when clearing stat boosts on player death.
    	ammoMaxBonus_add_raw(_index, _ammoType, _count);
    	ammoGainBonus_add_raw(_index, _ammoType, _count);
    	speedBonus_add_raw(_index, _speed);
    	reloadBonus_add_raw(_index, _bonus);
    	accuracyBonus_add_raw(_index, _bonus);
    	
    	
    */
    
    /*
        TODO
        rad max controller. i want to make a rad pouch trinket and radmaxpickups use one already
    */


	#macro minProjSpeedBonus		3
	#macro maxProjSpeedBonus		26
	
	#macro ammoMaxBonus    			GameCont.wib_ammoMaxBonus;
	#macro ammoGainBonus    		GameCont.wib_ammoGainBonus;
	#macro speedBonus				GameCont.wib_speedBonus;
	#macro reloadBonus				GameCont.wib_reloadBonus;
	#macro accuracyBonus			GameCont.wib_accuracyBonus;
	#macro projectileSpeedBonus		GameCont.wib_projectileSpeedBonus;
	#macro radMaxBonus				GameCont.wib_radMaxBonus;
	
	
	global.level_start		    			= (instance_exists(GenCont) || instance_exists(Menu));
    setup_gamecont();
    
#define setup_gamecont
    with(instances_matching(GameCont, "wibbly", null)){
        wibbly                      = true;
        wib_ammoMaxBonus			= [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]];
        wib_ammoGainBonus			= [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]];
        wib_speedBonus				= [0, 0, 0, 0];
        wib_reloadBonus				= [0, 0, 0, 0];
        wib_accuracyBonus			= [0, 0, 0, 0];
        wib_projectileSpeedBonus	= [0, 0, 0, 0];
        wib_wantStatsController     = false;
        wib_wantProjectileController= false;
        wib_radMaxBonus				= 0;
    }  
    global.wantRadMaxBuffer = false;

#define game_start
    setup_gamecont();

#define step
	if(instance_exists(GenCont) || instance_exists(Menu)){
		global.level_start = true;
	}
	else if(global.level_start){
		global.level_start = false;
		level_start();
	}
	
		// Max Rad Buffer:
	if(global.wantRadMaxBuffer = true){
	    with(instances_matching(instances_matching(GameCont, "level", 10), "wib_radMaxBuffered", null)){
			radMaxBonus_add(radMaxBonus) 
			wib_radMaxBuffered		= true;
			global.wantRadMaxBuffer = false;
	    }
	}

#define level_start
	 // Player Stat Bonuses Controller:
	if(GameCont.wib_wantStatsController	= true){
		PlayerStatsController_spawn();
	}
	
	 // Projectile Speed Bonus Controller:
	if(GameCont.wib_wantProjectileController = true){
		ProjectileSpeedController_spawn();
		
		// stop spawning controller if not needed:
		var _needController = false;
    	for(var _index = 0; _index < maxp; _index++){	
    		_needController += abs(projectileSpeedBonus[_index]);
    	}
    	if(!_needController){
    		GameCont.wib_wantProjectileController = false;
    	}
	}
	
	// input -1 to affect all players, raws don't have that
#define ammoMaxBonus_add(_index, _ammoType, _count)
	var _player = _index = -1 ? Player : instances_matching(Player, "index", _index);
    with(_player){
        typ_amax[_ammoType] += _count;
        ammoMaxBonus[index][@_ammoType - 1] += _count;
    }
    PlayerStatsController_spawn();

#define ammoGainBonus_add(_index, _ammoType, _count)
	var _player = _index = -1 ? Player : instances_matching(Player, "index", _index);
    with(_player){
        typ_ammo[_ammoType] += _count;
        ammoGainBonus[index][@_ammoType - 1] += _count;
    }
    PlayerStatsController_spawn();

#define speedBonus_add(_index, _speed)
	var _player = _index = -1 ? Player : instances_matching(Player, "index", _index);
    with(_player){
    	maxspeed += _speed;
    	speedBonus[index] += _speed;
    }
    PlayerStatsController_spawn();

#define reloadBonus_add(_index, _bonus)
	var _player = _index = -1 ? Player : instances_matching(Player, "index", _index);
    with(_player){
    	reloadspeed += _bonus;
    	reloadBonus[index] += _bonus;
    }
    PlayerStatsController_spawn();
    
#define accuracyBonus_add(_index, _bonus)
	var _player = _index = -1 ? Player : instances_matching(Player, "index", _index);
    with(_player){
    	accuracy -= _bonus;
    	if(accuracy < 0){ // negative makes it wrap around again
       		accuracy = 0;
    	}
    	accuracyBonus[index] += _bonus;
    }
    PlayerStatsController_spawn();

#define projectileSpeedBonus_add(_index, _bonus)
	var _player = _index = -1 ? Player : instances_matching(Player, "index", _index);
    with(_player){
    	projectileSpeedBonus[index] += _bonus;
    }
    ProjectileSpeedController_spawn();
    
#define radMaxBonus_add(_bonus)
		radMaxBonus += _bonus;
	if(GameCont.level != 10){
		global.wantRadMaxBuffer = true;
	} else {
		GameCont.radmaxextra += _bonus
		 // always keep 20 rad capacity at least.
		if(radMaxBonus < -580){
			GameCont.radmaxextra = -580;
		}
	}
    
#define ammoMaxBonus_add_raw(_index, _ammoType, _count)
    ammoMaxBonus[_index][@_ammoType - 1] += _count;
    PlayerStatsController_spawn();

#define ammoGainBonus_add_raw(_index, _ammoType, _count)
    ammoGainBonus[_index][@_ammoType - 1] += _count;
    PlayerStatsController_spawn();

#define speedBonus_add_raw(_index, _speed)
    speedBonus[_index] += _speed;
    PlayerStatsController_spawn();

#define reloadBonus_add_raw(_index, _bonus)
    reloadBonus[_index] += _bonus;
    PlayerStatsController_spawn();
    
#define accuracyBonus_add_raw(_index, _bonus)
    accuracyBonus[_index] += _bonus;
    PlayerStatsController_spawn();
    
#define PlayerStatsController_spawn
 	if(array_length(instances_matching(CustomObject, "name", "wib_PlayerStatsController")) = 0){
		PlayerStatsController_create(10016, 10016);
		GameCont.wib_wantStatsController = true;
	}

#define PlayerStatsController_create(_x, _y)
    with(instance_create(_x, _y, CustomObject)){
        name            = "wib_PlayerStatsController";
            
        prev_muscle     = skill_get(mut_back_muscle);
		livingPlayers	= [
							array_length(instances_matching(Player, "index", 0)), 
							array_length(instances_matching(Player, "index", 1)), 
							array_length(instances_matching(Player, "index", 2)), 
							array_length(instances_matching(Player, "index", 3))
						];
        
        on_step         = PlayerStatsController_step;
        
        return self;
    }
    
#define PlayerStatsController_step
	 // Fix if Back Muscle Changes:
    if(prev_muscle != skill_get(mut_back_muscle)){
        
         // apply ammo changes
        with(Player){
            var _ammoType = 1;
            repeat(5){
                typ_amax[_ammoType] += ammoMaxBonus[index][_ammoType - 1];
                _ammoType += 1;
            }
        }
        
         // remember....
        prev_muscle = skill_get(mut_back_muscle);
    }
    
	 // Reapply stat boosts on respawn
    for(var _index = 0; _index < maxp; _index++){
    	if(array_length(instances_matching(Player, "index", _index)) = 0){
    		livingPlayers[_index] = 0;	
    	} else {
    		 // player has respawned!! :)
    		if(livingPlayers[_index] = 0){
    			with(instances_matching(Player, "index", _index)){
	    			 // Reapply Max Ammo and Ammo Gain:
		            var _ammoType = 1;
		            repeat(5){
		                typ_amax[_ammoType] += ammoMaxBonus[index][_ammoType - 1];
		                typ_ammo[_ammoType] += ammoGainBonus[index][_ammoType - 1];	               
		                _ammoType += 1;
		            }			
		            
		            // Reapply Max Speed:
		           maxspeed += speedBonus[index];
		           
		            // Reapply Reload Speed:
		           reloadspeed += reloadBonus[index];	            
		            
		        	// Reapply Accuracy:
		           accuracy -= accuracyBonus[index];	  
		           if(accuracy < 0){ // negative makes it wrap around again
		           		accuracy = 0;
		           }
    			}
    		}
    		livingPlayers[_index] = 1;	
    	}
    }

#define ProjectileSpeedController_spawn
 	if(array_length(instances_matching(CustomObject, "name", "wib_ProjectileSpeedController")) = 0){
		ProjectileSpeedController_create(10016, 10016);
		GameCont.wib_wantProjectileController = true;
	}
	
#define ProjectileSpeedController_create(_x, _y)
    with(instance_create(_x, _y, CustomObject)){
        name            = "wib_ProjectileSpeedController";
        
        on_step         = ProjectileSpeedController_step;
        
        return self;
    }
    
#define ProjectileSpeedController_step
	if(instance_exists(projectile)){
		with(Player){
			var _proj = instances_matching(instances_matching(projectile, "wib_projspeed", null), "creator", self.id),
				_index = index;
			
			if(array_length(_proj)){
				with(_proj){
					wib_projspeed = true;
					if("is_melee" not in self || is_melee = false){
						if(array_find_index([TangleSeed, ThrownWep, HorrorBullet, ToxicGas, Laser, EnemyLaser, Slash, LightningSlash, EnergySlash, EnergyHammerSlash, BloodSlash, Shank, EnergyShank, GuitarSlash], object_index) == - 1){
							var _ogSpeed	= speed,
								_speedBonus = projectileSpeedBonus[_index],
								_newSpeed	= _ogSpeed;
								
							if(_ogSpeed > 0 && _ogSpeed < maxProjSpeedBonus){
								_newSpeed = clamp(_ogSpeed * (1 + _speedBonus), minProjSpeedBonus, maxProjSpeedBonus);
							}
							speed = _newSpeed;
						}
						
						 // they hardcoded these yay...
						if(array_find_index([Nuke, Rocket, PlasmaBall, PlasmaBig, PlasmaHuge], object_index) + 1){
							switch(object_index){
								case PlasmaBall:
								case Seeker:
								case Nuke:
									_ogSpeed	= 7;
								break;
								case PlasmaBig:
								case PlasmaHuge:
									_ogSpeed	= 6;
								break;
								case Rocket:
									_ogSpeed	= 12;
								break;
							}
							
							_newSpeed = clamp(_ogSpeed * (1 + _speedBonus), minProjSpeedBonus, maxProjSpeedBonus);
							if fork(){
								while(instance_exists(self)){ 
									speed = (_newSpeed)
									wait 0;
								}
								exit;
							}
						}
					}
				}
			}
		}
	}
    
#define init
    // WIGGLERCOLA ULTIMATE SHARED FUNCTION LIBRARY!!!!!!!! //
    /*
        CURRENT FEATURES
        PERSISTANT MAX AMMO WITH BACK MUSCLE CHANGES!
    
    
    */
    
    /*
        TODO
        make max ammo bonuses persistant in multiplayer
        probably just do something like this in level_start
        i dont care enough about it to make it run all the time
        (amax != 55 + bonus){
            apply max ammo
        }
    
    */
    
    trace("WIBBLY LOADED!!");
    
    setup_gamecont();
#define setup_gamecont
    with(instances_matching(GameCont, "wibbly", null)){
        wibbly                      = true;
        wib_ammobonus			    = [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]];
        wib_wantmusclefixer         = false;
    }  
    
#macro ammoBonus    GameCont.wib_ammobonus;

#define game_start
    setup_gamecont();
    


/*
    run controller spawn when max ammo change applies probably
    run controller spawn on level start if wantmusclefixer is true
    ammobonus goes like [[bulletbonus, shellbonus, boltbonus, explobonus, energybonus], [...], [...], [...]] each array is for player index
    u can probably decrease ammo with this too
*/
#define maxAmmo_add(_index, _ammoType, _count)
    with(instances_matching(Player, "index", _index)){
        typ_amax[_ammoType] += _count;
    }
    ammoBonus[_index][@_ammoType] += _count;
    BackMuscleController_spawn();
    
#define maxAmmo_add_raw(_index, _ammoType, _count)
     // just in case you dont need the type increase automatically for some reason
    ammoBonus[_index][@_ammoType] += _count;
    BackMuscleController_spawn();
    
#define BackMuscleController_spawn
 	if(array_length(instances_matching(CustomObject, "name", "wib_backMuscleController")) = 0){
		BackMuscleController_create(10016, 10016);
	}

#define BackMuscleController_create(_x, _y)
    with(instance_create(_x, _y, CustomObject)){
        name            = "wib_backMuscleController";
            
        prev_muscle     = skill_get(mut_back_muscle);
        
        on_step         = BackMuscleController_step;
        
        return self;
    }
    
#define BackMuscleController_step
    if(prev_muscle != skill_get(mut_back_muscle)){
        
         // apply ammo changes
        with(Player){
            var _ammoType = 0;
            repeat(5){
                typ_amax[_ammoType + 1] += GameCont.wib_ammobonus[index][_ammoType];
                _ammoType += 1;
            }
        }
        
         // remember....
        prev_muscle = skill_get(mut_back_muscle);
    }
    
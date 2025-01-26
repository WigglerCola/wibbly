#define init
    trace("WIBBLY 0.2.1 LOADED!!");
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
        rad max controller. i want to make a rad pouch trinket
    */
    
    setup_gamecont();
#define setup_gamecont
    with(instances_matching(GameCont, "wibbly", null)){
        wibbly                      = true;
        wib_ammoBonus			    = [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0]];
        wib_wantMaxAmmoFixer        = false;
    }  
    
#macro ammoBonus    GameCont.wib_ammoBonus;

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
    ammoBonus[_index][@_ammoType - 1] += _count;
    MaxAmmoController_spawn();
    
#define maxAmmo_add_raw(_index, _ammoType, _count)
     // just in case you dont need the type increase automatically for some reason
    ammoBonus[_index][@_ammoType - 1] += _count;
    MaxAmmoController_spawn();
    
#define MaxAmmoController_spawn
 	if(array_length(instances_matching(CustomObject, "name", "wib_maxAmmoController")) = 0){
		MaxAmmoController_create(10016, 10016);
		GameCont.wib_wantMaxAmmoFixer = true;
	}

#define MaxAmmoController_create(_x, _y)
    with(instance_create(_x, _y, CustomObject)){
        name            = "wib_maxAmmoController";
            
        prev_muscle     = skill_get(mut_back_muscle);
        
        on_step         = MaxAmmoController_step;
        
        return self;
    }
    
#define MaxAmmoController_step
    if(prev_muscle != skill_get(mut_back_muscle)){
        
         // apply ammo changes
        with(Player){
            var _ammoType = 1;
            repeat(5){
                typ_amax[_ammoType] += ammoBonus[index][_ammoType - 1];
                _ammoType += 1;
            }
        }
        
         // remember....
        prev_muscle = skill_get(mut_back_muscle);
    }
    
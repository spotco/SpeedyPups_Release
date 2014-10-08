#import "MapLoader.h"

#import "JSONKit.h"
#import "GameItemCommon.h"

#import "LineIsland.h"
#import "Island.h"
#import "CaveLineIsland.h"
#import "BridgeIsland.h"
#import "LabLineIsland.h"

#import "DogBone.h"
#import "GroundDetail.h"
#import "DogCape.h"
#import "CheckPoint.h"
#import "Spike.h"
#import "Water.h"
#import "JumpPad.h"
#import "BirdFlock.h"
#import "Blocker.h"
#import "SpeedUp.h"
#import "RocketWall.h"
#import "IslandFill.h"
#import "BreakableWall.h"
#import "SpikeVine.h"
#import "CameraArea.h"
#import "SwingVine.h"
#import "MinionRobot.h"
#import "LauncherRobot.h"
#import "FadeOutLabWall.h"
#import "CopterRobotLoader.h"
#import "ElectricWall.h"
#import "LabEntrance.h"
#import "LabExit.h"
#import "EnemyAlert.h"
#import "TutorialLauncher.h"
#import "TutorialEnd.h"
#import "ChallengeEnd.h"
#import "Coin.h"
#import "FreeRunProgressDisplay.h"
#import "ItemGen.h"
#import "OneUpObject.h"
#import "LabHandRail.h"
#import "SubBossLoader.h"
#import "Cannon.h"
#import "RobotBossLoader.h" 
#import "TreatPickup.h"

#import "CapeGameBone.h"
#import "CapeGameSpikeVine.h"
#import "CapeTutorialLauncher.h"
#import "CapeGameEnd.h"

@implementation GameMap
    @synthesize assert_links;
    @synthesize connect_pts_x1,connect_pts_x2,connect_pts_y1,connect_pts_y2;
    @synthesize game_objects,n_islands;
    @synthesize player_start_pt;
@end

@implementation MapLoader

#define DOTMAP @"map"

static MapLoaderMode cur_mode = MapLoaderMode_AUTO;

+(void)set_maploader_mode:(MapLoaderMode)m {
	cur_mode = m;
}

static NSMutableDictionary* cached_json;

+(void) precache_map:(NSString *)map_file_name {
    if (cached_json == NULL) {
        cached_json = [[NSMutableDictionary alloc] init];
    }
    if ([cached_json objectForKey:map_file_name]) {
        return;
    }
    
    NSString *islandFilePath = [[NSBundle mainBundle] pathForResource:map_file_name ofType:DOTMAP];
	NSString *islandInputStr = [[NSString alloc] initWithContentsOfFile : islandFilePath encoding:NSUTF8StringEncoding error:NULL];
   
#if 1
	NSDictionary *j_map_data = [islandInputStr objectFromJSONString];
#else
	NSError *e = nil;
	NSDictionary *j_map_data = [NSJSONSerialization
						  JSONObjectWithData:[islandInputStr dataUsingEncoding:NSUTF8StringEncoding]
						  options: NSJSONReadingMutableContainers
						  error: &e];
	if (e) NSLog(@"%@",e);
#endif
	
	[cached_json setValue:j_map_data forKey:map_file_name];
}

+(NSDictionary*)get_jsondict:(NSString *)map_file_name {
	
    if (![cached_json objectForKey:map_file_name]) {
        [MapLoader precache_map:map_file_name];
    }
    return [cached_json objectForKey:map_file_name];
	
	/*
    NSString *islandFilePath = [[NSBundle mainBundle] pathForResource:map_file_name ofType:DOTMAP];
	NSString *islandInputStr = [[NSString alloc] initWithContentsOfFile : islandFilePath encoding:NSUTF8StringEncoding error:NULL];
	return [islandInputStr objectFromJSONString];
	*/
}

+(GameMap*) load_map:(NSString *)map_file_name g:(GameEngineLayer *)g {
    NSDictionary *j_map_data = [MapLoader get_jsondict:map_file_name];
    
    NSArray *islandArray = [j_map_data objectForKey:(@"islands")];
	int islandsCount = (int)[islandArray count];
	
    GameMap *map = [[GameMap alloc] init];
    map.n_islands = [[NSMutableArray alloc] init];
    map.game_objects = [[NSMutableArray alloc] init];
    
    float start_x = getflt(j_map_data, @"start_x");
	float start_y = getflt(j_map_data, @"start_y");
    map.player_start_pt = ccp(start_x,start_y);
    //NSLog(@"Player starting at (%f,%f)",start_x,start_y);
    
    int assert_links = ((NSString*)[j_map_data objectForKey:(@"assert_links")]).intValue;
    map.assert_links = assert_links;
    
    NSDictionary* connect_pts = [j_map_data objectForKey:(@"connect_pts")];
    if(connect_pts != NULL) {
        map.connect_pts_x1 = getflt(connect_pts, @"x1");
        map.connect_pts_x2 = getflt(connect_pts, @"x2");
        map.connect_pts_y1 = getflt(connect_pts, @"y1");
        map.connect_pts_y2 = getflt(connect_pts, @"y2");
    }
    
	for(int i = 0; i < islandsCount; i++){
		NSDictionary *currentIslandDict = (NSDictionary *)[islandArray objectAtIndex:i];
        CGPoint start = ccp(getflt(currentIslandDict,@"x1"),getflt(currentIslandDict,@"y1"));
        CGPoint end = ccp(getflt(currentIslandDict,@"x2"),getflt(currentIslandDict,@"y2"));
        
        Island *currentIsland;
        
        float height = getflt(currentIslandDict, @"hei");
        NSString *ndir_str = [currentIslandDict objectForKey:@"ndir"];
        
        float ndir = 0;
        if ([ndir_str isEqualToString:@"left"]) {
            ndir = 1;
        } else if ([ndir_str isEqualToString:@"right"]) {
            ndir = -1;
        }
        BOOL can_land = ((NSString *)[currentIslandDict objectForKey:@"can_fall"]).boolValue;
        
        NSString *ground_type = (NSString *)[currentIslandDict objectForKey:@"ground"];
        
        if (ground_type == NULL || [ground_type isEqualToString:@"open"]) {
            currentIsland = [LineIsland cons_pt1:start pt2:end height:height ndir:ndir can_land:can_land g:g];
        } else if ([ground_type isEqualToString:@"cave"]) {
            currentIsland = [CaveLineIsland cons_pt1:start pt2:end height:height ndir:ndir can_land:can_land];
        } else if ([ground_type isEqualToString:@"bridge"]) {
            currentIsland = [BridgeIsland cons_pt1:start pt2:end height:height ndir:ndir can_land:can_land];
        } else if ([ground_type isEqualToString:@"lab"]) {
            currentIsland = [LabLineIsland cons_pt1:start pt2:end height:height ndir:ndir can_land:can_land];
        } else {
            NSLog(@"unrecognized ground type!!");
            continue;
        }
		[map.n_islands addObject:currentIsland];
	}
    
    
    NSArray *coins_array = [j_map_data objectForKey:@"objects"];
    
    for(int i = 0; i < [coins_array count]; i++){
		int cur_size = (int)[map.game_objects count];
        NSDictionary *j_object = (NSDictionary *)[coins_array objectAtIndex:i];
        NSString *type = (NSString *)[j_object objectForKey:@"type"];
        
        if([type isEqualToString:@"dogbone"]){
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            int bid = ((NSString*)[j_object  objectForKey:@"bid"]).intValue;
            [map.game_objects addObject:[DogBone cons_x:x y:y bid:bid]];
            
            
        } else if ([type isEqualToString:@"dogcape"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
			if ([j_object objectForKey:@"label"]) {
				[map.game_objects addObject:[DogCape cons_x:x y:y map:[j_object objectForKey:@"label"]]];
			} else {
				[map.game_objects addObject:[DogCape cons_x:x y:y]];
			}
            
            
        } else if ([type isEqualToString:@"dogrocket"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[ItemGen cons_pt:ccp(x,y) item:Item_Rocket]];
			
		} else if ([type isEqualToString:@"dogarmor"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[ItemGen cons_pt:ccp(x,y) item:Item_Shield]];
			
		} else if ([type isEqualToString:@"dogrocketend"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");
            float hei = getflt(j_object, @"height");
			[map.game_objects addObject:[DogRocketWall cons_x:x y:y width:width height:hei]];
			
        } else if ([type isEqualToString:@"ground_detail"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            int type = ((NSString*)[j_object  objectForKey:@"img"]).intValue;
            [map.game_objects addObject:[GroundDetail cons_x:x y:y type:type islands:map.n_islands g:g]];
            
        } else if ([type isEqualToString:@"spike"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[Spike cons_x:x y:y islands:map.n_islands]];
            
        } else if ([type isEqualToString:@"water"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");
            float hei = getflt(j_object, @"height");
            [map.game_objects addObject:[Water cons_x:x y:y width:width height:hei]];
            
        } else if ([type isEqualToString:@"jumppad"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            
            NSDictionary* dir_obj = [j_object objectForKey:@"dir"];
            float dir_x = getflt(dir_obj, @"x");;
            float dir_y = getflt(dir_obj, @"y");;
            Vec3D dir_vec = [VecLib cons_x:dir_x y:dir_y z:0];
            [map.game_objects addObject:[JumpPad cons_x:x y:y dirvec:dir_vec]];
            
            
        } else if ([type isEqualToString:@"birdflock"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[BirdFlock cons_x:x y:y]];
            
        } else if([type isEqualToString:@"blocker"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");;
            float height = getflt(j_object, @"height");;
            
            [map.game_objects addObject:[Blocker cons_x:x y:y width:width height:height]];
            
        } else if([type isEqualToString:@"speedup"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            
            NSDictionary* dir_obj = [j_object objectForKey:@"dir"];
            float dir_x = getflt(dir_obj, @"x");
            float dir_y = getflt(dir_obj, @"y");
            Vec3D dir_vec = [VecLib cons_x:dir_x y:dir_y z:0];
            [map.game_objects addObject:[SpeedUp cons_x:x y:y dirvec:dir_vec]];
            
            
        } else if ([type isEqualToString:@"cavewall"] || [type isEqualToString:@"rocketwall"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");
            float hei = getflt(j_object, @"height");
            [map.game_objects addObject:[RocketWall cons_x:x y:y width:width height:hei]];
            
        } else if ([type isEqualToString:@"island_fill"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");
            float hei = getflt(j_object, @"height");
            [map.game_objects addObject:[IslandFill cons_x:x y:y width:width height:hei g:g]];
            
        } else if ([type isEqualToString:@"breakable_wall"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float x2 = getflt(j_object, @"x2");
            float y2 = getflt(j_object, @"y2");
            [map.game_objects addObject:[BreakableWall cons_x:x y:y x2:x2 y2:y2]];
            
        } else if ([type isEqualToString:@"spikevine"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float x2 = getflt(j_object, @"x2");
            float y2 = getflt(j_object, @"y2");
            [map.game_objects addObject:[SpikeVine cons_x:x y:y x2:x2 y2:y2]];
            
        } else if ([type isEqualToString:@"camera_area"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");
            float hei = getflt(j_object, @"height");
            
            NSDictionary* dir_obj = [j_object objectForKey:@"camera"];
            float cx = getflt(dir_obj, @"x");
            float cy = getflt(dir_obj, @"y");
            float cz = getflt(dir_obj, @"z");
            struct CameraZoom n = [Common cons_normalcoord_camera_zoom_x:cx y:cy z:cz];
            [map.game_objects addObject:[CameraArea cons_x:x y:y wid:width hei:hei zoom:n]];
            
        } else if ([type isEqualToString:@"swingvine"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float x2 = getflt(j_object, @"x2");;
            float y2 = getflt(j_object, @"y2");;
            float len = sqrtf(powf(x2-x, 2)+powf(y2-y, 2));
            [map.game_objects addObject:[SwingVine cons_x:x y:y len:len]];
            
        } else if ([type isEqualToString:@"robotminion"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[MinionRobot cons_x:x y:y]];
            
        } else if ([type isEqualToString:@"launcherrobot"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            NSDictionary* dir_obj = [j_object objectForKey:@"dir"];
            float dir_x = getflt(dir_obj, @"x");
            float dir_y = getflt(dir_obj, @"y");
            Vec3D dir_vec = [VecLib cons_x:dir_x y:dir_y z:0];
            [map.game_objects addObject:[LauncherRobot cons_x:x y:y dir:dir_vec]];
            
        } else if ([type isEqualToString:@"labwall"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");
            float hei = getflt(j_object, @"height");
            [map.game_objects addObject:[FadeOutLabWall cons_x:x y:y width:width height:hei]];
            
        } else if ([type isEqualToString:@"copter"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[CopterRobotLoader cons_x:x y:y]];
            
        } else if ([type isEqualToString:@"electricwall"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float x2 = getflt(j_object, @"x2");
            float y2 = getflt(j_object, @"y2");
            [map.game_objects addObject:[ElectricWall cons_x:x y:y x2:x2 y2:y2]];
            
        } else if ([type isEqualToString:@"labentrance"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[LabEntrance cons_pt:ccp(x,y)]];
            
        } else if ([type isEqualToString:@"labexit"]) {
			NSLog(@"ATTEMPTED LABEXIT SOMETHINGS WRONG HERE");
			
        } else if ([type isEqualToString:@"enemyalert"]) {
            [map.game_objects addObject:[EnemyAlert cons_p1:ccp(getflt(j_object, @"x"),getflt(j_object, @"y"))
                                                       size:ccp(getflt(j_object, @"width"),getflt(j_object, @"height"))]];
            
        } else if ([type isEqualToString:@"tutorial"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            NSString *msg = [j_object objectForKey:@"label"];
            [map.game_objects addObject:[TutorialLauncher cons_pos:ccp(x,y) anim:msg]];
            
        } else if ([type isEqualToString:@"tutorialend"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            [map.game_objects addObject:[TutorialEnd cons_pos:ccp(x,y)]];
			
		} else if ([type isEqualToString:@"progressdisp"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
			BOOL is_lab = streq([j_object objectForKey:@"label"],@"lab");
			//NSLog(@"%d",is_lab);
            [map.game_objects addObject:[FreeRunProgressDisplay cons_pt:ccp(x,y) lab:is_lab]];
			
		} else if ([type isEqualToString:@"labfill"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float width = getflt(j_object, @"width");
            float hei = getflt(j_object, @"height");
            [map.game_objects addObject:[LabFill cons_x:x y:y width:width height:hei g:g]];
			
		} else if ([type isEqualToString:@"itemgen"]) {
			float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
			[map.game_objects addObject:[ItemGen cons_pt:ccp(x,y)]];
			
        } else if ([type isEqualToString:@"handrail"]) {
			float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float x2 = getflt(j_object, @"x2");
            float y2 = getflt(j_object, @"y2");
			[map.game_objects addObject:[LabHandRail cons_pt1:ccp(x,y) pt2:ccp(x2,y2)]];
			
		} else if ([type isEqualToString:@"subbossloader"]) {
			float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
			[map.game_objects addObject:[SubBossLoader cons_pt:ccp(x,y)]];
			
		} else if ([type isEqualToString:@"cannon"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            
            NSDictionary* dir_obj = [j_object objectForKey:@"dir"];
            float dir_x = getflt(dir_obj, @"x");
            float dir_y = getflt(dir_obj, @"y");
			[map.game_objects addObject:[Cannon cons_pt:ccp(x,y) dir:ccp(dir_x,dir_y)]];
			
		} else if ([type isEqualToString:@"cannonmovetrack"]) {
			float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float x2 = getflt(j_object, @"x2");
            float y2 = getflt(j_object, @"y2");
			[map.game_objects addObject:[CannonMoveTrack cons_pt1:ccp(x,y) pt2:ccp(x2,y2)]];
			
		} else if ([type isEqualToString:@"cannonrotationpoint"]) {
			float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float x2 = getflt(j_object, @"x2");
            float y2 = getflt(j_object, @"y2");
			[map.game_objects addObject:[CannonRotationPoint cons_pt1:ccp(x,y) pt2:ccp(x2,y2)]];
			
		} else if ([type isEqualToString:@"robotbossloader"]) {
			float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
			[map.game_objects addObject:[RobotBossLoader cons_pt:ccp(x,y)]];
			
		} else if (streq(type, @"coin")) {
			float x = getflt(j_object, @"x");
			float y = getflt(j_object, @"y");
			[map.game_objects addObject:[Coin cons_pt:ccp(x,y)]];
			
		}
		
		if (cur_mode == MapLoaderMode_AUTO) {
			if ([type isEqualToString:@"treat"]) {
				float x = getflt(j_object, @"x");
				float y = getflt(j_object, @"y");
				[map.game_objects addObject:[OneUpObject cons_pt:ccp(x,y)]];
				
			} else if ([type isEqualToString:@"1upobject"]) {
				float x = getflt(j_object, @"x");
				float y = getflt(j_object, @"y");
				OneUpObject *rtv = [OneUpObject cons_pt:ccp(x,y)];
				if (getbool(j_object, @"cond")) [rtv set_only_appear_if_below_threshold];
				[map.game_objects addObject:rtv];
				
				
			} else if ([type isEqualToString:@"checkpoint"]) {
				float x = getflt(j_object, @"x");
				float y = getflt(j_object, @"y");
				[map.game_objects addObject:[CheckPoint cons_x:x y:y]];
			}
			
		} else if (cur_mode == MapLoaderMode_CHALLENGE) {
			if ([type isEqualToString:@"game_end"]) {
				float x = getflt(j_object, @"x");
				float y = getflt(j_object, @"y");
				[map.game_objects addObject:[ChallengeEnd cons_pt:ccp(x,y)]];
				
			} else if ([type isEqualToString:@"treat"]) {
				float x = getflt(j_object, @"x");
				float y = getflt(j_object, @"y");
				[map.game_objects addObject:[TreatPickup cons_pt:ccp(x,y)]];
				
			} else if ([type isEqualToString:@"checkpoint"]) {
				if (streq(@"force",(NSString*)[j_object objectForKey:@"label"])) {
					float x = getflt(j_object, @"x");
					float y = getflt(j_object, @"y");
					[map.game_objects addObject:[CheckPoint cons_x:x y:y]];
				} else {
					NSLog(@"%@",[j_object objectForKey:@"label"]);
				}
			}
		}
		
		if ([map.game_objects count] == cur_size) {
			NSLog(@"map loader error on:%@",type);
		}
		
    }

    //NSLog(@"finish parse");
    return map;
}

float getflt(NSDictionary* j_object,NSString* key) {
    return ((NSString*)[j_object objectForKey:key]).floatValue;
}

BOOL getbool(NSDictionary* j_object,NSString* key) {
    return ((NSString*)[j_object objectForKey:key]).boolValue;
}

+(GameMap*)load_capegame_map:(NSString *)map_file_name {
    NSDictionary *j_map_data = [MapLoader get_jsondict:map_file_name];
    GameMap *map = [[GameMap alloc] init];
	map.game_objects = [NSMutableArray array];
	map.n_islands = NULL;
	
    NSArray *coins_array = [j_map_data objectForKey:@"objects"];
    for(int i = 0; i < [coins_array count]; i++){
        NSDictionary *j_object = (NSDictionary *)[coins_array objectAtIndex:i];
        NSString *type = (NSString *)[j_object objectForKey:@"type"];
        
        if([type isEqualToString:@"dogbone"]){
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
			[map.game_objects addObject:[CapeGameBone cons_pt:ccp(x,y)]];
			
        } else if ([type isEqualToString:@"spikevine"]) {
            float x = getflt(j_object, @"x");
            float y = getflt(j_object, @"y");
            float x2 = getflt(j_object, @"x2");
            float y2 = getflt(j_object, @"y2");
			[map.game_objects addObject:[CapeGameSpikeVine cons_pt1:ccp(x,y) pt2:ccp(x2,y2)]];
			
		} else if ([type isEqualToString:@"tutorial"]) {
            float x = getflt(j_object, @"x");
			[map.game_objects addObject:[CapeTutorialLauncher cons_x:x]];
			
		} else if ([type isEqualToString:@"game_end"]) {
			float x = getflt(j_object, @"x");
			float y = getflt(j_object, @"y");
			[map.game_objects addObject:[CapeGameEnd cons_pt:ccp(x,y)]];
			
			
		} else if (streq(type,@"treat")) {
			float x = getflt(j_object, @"x");
			float y = getflt(j_object, @"y");
			if (cur_mode == MapLoaderMode_CHALLENGE) {
				[map.game_objects addObject:[CapeGameTreatObject cons_pt:ccp(x,y)]];
			} else {
				[map.game_objects addObject:[CapeGameOneUpObject cons_pt:ccp(x,y)]];
			}
		}
	}
	
	return map;
}

@end

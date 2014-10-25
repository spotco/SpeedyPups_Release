#import "GameEngineLayer.h"
#import "BGLayer.h"
#import "UILayer.h"
#import "FlashEffect.h"
#import "TouchTrackingLayer.h"
#import "GameItemCommon.h"
#import "UserInventory.h"
#import "OneUpParticle.h"
#import "GameModeCallback.h"
#import "BGTimeManager.h"
#import "CapeGameEngineLayer.h"
#import "TutorialEnd.h"
#import "DogBone.h"
#import "FreePupsAnim.h"
#import "ObjectPool.h"
#import "ScoreManager.h"
#import "TrackingUtil.h"
#import "BossRushAutoLevel.h"
#import "BatchSpriteManager.h"
#import "AdColony_integration.h" 

@implementation GameEngineLayer {
	BOOL first_update;
	NSString *capegame_level_to_load;
	
	float _camera_x;
	float _camera_y;
	float _camera_z;
	
	BatchSpriteManager *particle_holder;
}

#define tBGLAYER 2
#define tGLAYER 3
#define tFGLAYER 4
#define tUILAYER 5
#define tTTRACKLAYER 6
#define tFADEOUTLAYER 7

#define DEFAULT_CONTINUE_COST 1

@synthesize current_mode;
@synthesize game_objects,islands;
@synthesize player;
@synthesize camera_state,tar_camera_state;
@synthesize world_mode;
@synthesize score;

+(CCScene *)scene_with:(NSString *)map_file_name lives:(int)lives world:(WorldNum)world {
    CCScene *scene = [CCScene node];
    GameEngineLayer *glayer = [GameEngineLayer layer_from_file:map_file_name lives:lives world:world];
	BGLayer *bglayer = [BGLayer cons_with_gamelayer:glayer];
    UILayer* uilayer = [UILayer cons_with_gamelayer:glayer];
    
    [scene addChild:[CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)]];
    [scene addChild:bglayer z:0 tag:tBGLAYER];
    [scene addChild:glayer z:0 tag:tGLAYER];
	[scene addChild:[TouchTrackingLayer node] z:0 tag:tTTRACKLAYER];
    [scene addChild:uilayer z:0 tag:tUILAYER];
	[scene addChild:[CCLayerColor layerWithColor:ccc4(0,0,0,0)] z:999 tag:tFADEOUTLAYER];
	
	return scene;
}
+(CCScene*) scene_with_autolevel_lives:(int)lives world:(WorldStartAt)world {
    CCScene* scene = [GameEngineLayer scene_with:@"connector" lives:lives world:world.world_num];
    GameEngineLayer* glayer = (GameEngineLayer*)[scene getChildByTag:tGLAYER];
    AutoLevel* nobj = [AutoLevel cons_with_glayer:glayer startat:world];
	[glayer.game_objects addObject:nobj]; //don't change this
    [glayer addChild:nobj];
    
    UILayer* uil = (UILayer*)[scene getChildByTag:tUILAYER];
    [uil set_retry_callback:[GameModeCallback cons_mode:GameMode_FREERUN n:0]];
    
    [nobj update:glayer.player g:glayer]; //have first section preloaded
    
	[glayer update_render];
    [glayer move_player_toground];
    [glayer prep_runin_anim];
	
	[uil start_freeruninfocard_anim];
	
	return scene;
}

+(CCScene*)scene_with_challenge:(ChallengeInfo*)info world:(WorldNum)world {
	[MapLoader set_maploader_mode:MapLoaderMode_CHALLENGE];
    CCScene* scene = [GameEngineLayer scene_with:info.map_name lives:GAMEENGINE_INF_LIVES world:world];
	[MapLoader set_maploader_mode:MapLoaderMode_AUTO];
    GameEngineLayer* glayer = (GameEngineLayer*)[scene getChildByTag:tGLAYER];
    
    UILayer* uil = (UILayer*)[scene getChildByTag:tUILAYER];
    [uil set_retry_callback:[GameModeCallback cons_mode:GameMode_CHALLENGE n:[ChallengeRecord get_number_for_challenge:info]]];
	
	[glayer set_challenge:info];
	
	[glayer update_render];
    [glayer move_player_toground];
    [glayer prep_runin_anim];
	
	[uil start_challengeinfocard_anim];
	
    return scene;
}

+(GameEngineLayer*)layer_from_file:(NSString*)file lives:(int)lives world:(WorldNum)world {
    GameEngineLayer *g = [GameEngineLayer node];
    [g cons:file lives:lives world:world];
    return g;
}

-(UILayer*)get_ui_layer {
	return (UILayer*)[[self parent] getChildByTag:tUILAYER];
}

-(GameEngineStats*)get_stats {
	return stats;
}

-(void)play_worldnum_bgm {
	if (world_mode.cur_world == WorldNum_1) {
		[AudioManager playbgm_imm:BGM_GROUP_WORLD1];
		
	} else if (world_mode.cur_world == WorldNum_2) {
		[AudioManager playbgm_imm:BGM_GROUP_WORLD2];
		
	} else if (world_mode.cur_world == WorldNum_3) {
		[AudioManager playbgm_imm:BGM_GROUP_WORLD3];
		
	}
}

-(void)cons:(NSString*)map_filename lives:(int)starting_lives world:(WorldNum)world {
    if (particles_tba == NULL) {
        particles_tba = [[NSMutableArray alloc] init];
    }
	
	particle_holder = [BatchSpriteManager cons:self];
	
	_camera_x = 0;
	_camera_y = 0;
	_camera_z = 1;
	
	capegame_level_to_load = NULL;
	[self setScaleX:1];
	[self setScaleY:1];
	
	first_update = NO;
	score = [ScoreManager cons];
	world_mode = [GameWorldMode cons_worldnum:world];
	[DogBone reset_play_collect_sound];
	stats = [GameEngineStats cons];
	
	if (starting_lives != GAMEENGINE_INF_LIVES) {
		if ([Player current_character_has_power:CharacterPower_DOUBLELIVES]) {
			default_starting_lives = [GameMain GET_DEFAULT_STARTING_LIVES] * 2;
		} else {
			default_starting_lives = [GameMain GET_DEFAULT_STARTING_LIVES];
		}
		lives = starting_lives;
		
	} else {
		default_starting_lives = GAMEENGINE_INF_LIVES;
		lives = GAMEENGINE_INF_LIVES;
	}
	
    
    [GameControlImplementation reset_control_state];
    [GEventDispatcher add_listener:self];
    refresh_viewbox_cache = YES;
    CGPoint player_start_pt = [self loadMap:map_filename];
    particles = [[NSMutableArray alloc] init];
    gameobjects_tbr = [NSMutableArray array];
    player = [Player cons_at:player_start_pt];
    [self follow_player];
    [self addChild:player z:[GameRenderImplementation GET_RENDER_PLAYER_ORD]];
    
    DogShadow *d = [DogShadow cons];
    [self.game_objects addObject:d];
    [self addChild:d z:[d get_render_ord]];
    
    
    self.isTouchEnabled = YES;
    
    
    int draw_ctx_z[] =  {
        [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND],
        [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD],
        [GameRenderImplementation GET_RENDER_GAMEOBJ_ORD],
        [GameRenderImplementation GET_RENDER_ISLAND_ORD]
    };
    for (int i = 0; i < arrlen(draw_ctx_z); i++) {
        [self addChild:[BatchDraw node] z:draw_ctx_z[i]];
    }
    
    [self reset_camera];
    
    [self update_render];
    [self schedule:@selector(update:)];
	
    
    current_mode = GameEngineLayerMode_SCROLLDOWN;
	
	shake_ct = 0;
	shake_intensity = 0;
	 
	current_continue_cost = DEFAULT_CONTINUE_COST;
    player_starting_pos = player_start_pt;
	[Common unset_dt];
	
	[self play_worldnum_bgm];
}

-(void)set_challenge:(ChallengeInfo*)info {
    [GEventDispatcher immediate_event:[[GEvent cons_type:GEventType_CHALLENGE] add_key:@"challenge" value:info]];
    for (GameObject *o in game_objects) {
        [o notify_challenge_mode:info];
    }
    challenge = info;
	
	if (info.type == ChallengeType_BOSSRUSH) {
		BossRushAutoLevel *brav = [BossRushAutoLevel cons_with_glayer:self];
		[self add_gameobject:brav];
		[brav update:player g:self];
	}
}

-(ChallengeInfo*)get_challenge {
	return challenge;
}

-(void)move_player_toground {
    CGPoint pos = player.position;
    for (Island* i in islands) {
        if (pos.x > i.endX || pos.x < i.startX) continue;
        float ipos = [i get_height:pos.x];
        if (ipos != [Island NO_VALUE] && pos.y > ipos && (pos.y - ipos)) {
            player.position = ccp(player.position.x,ipos);
            player.current_island = i;
            player_starting_pos = player.position;
            return;
        }
    }
}

-(void)prep_runin_anim {
    [player setVisible:NO];
	[self reset_follow_clamp_y];
    do_runin_anim = YES;
	scrollup_pct = 1;
	[GEventDispatcher immediate_event:[[GEvent cons_type:GEventType_MENU_SCROLLBGUP_PCT] add_f1:scrollup_pct f2:0]];
	[self follow_player];
}

-(void)update_render {
    [BatchDraw clear];
    for (GameObject *o in game_objects) {
        [o check_should_render:self];
    }
    for (Island *i in islands) {
        [i check_should_render:self];
    }
    [BatchDraw sort_jobs];
}

-(CGPoint)loadMap:(NSString*)filename {
	GameMap *map = [MapLoader load_map:filename g:self];
    
    islands = map.n_islands;
    int ct = [Island link_islands:islands];
    if (ct != map.assert_links) {
        NSLog(@"ERROR: expected %i links, got %i.",map.assert_links,ct);
    }
    
    for (Island* i in islands) {
        [self addChild:i z:[i get_render_ord]];
	}
    
    game_objects = map.game_objects;
    for (GameObject* o in game_objects) {
        [self addChild:o z:[o get_render_ord]];
    }
    
    World1ParticleGenerator *w1 = [World1ParticleGenerator cons];
    [game_objects addObject:w1];
    [self addChild:w1];
    
    return map.player_start_pt;
}

-(void)player_reset {
	[score reset_multiplier];
    if (challenge != NULL) {
        collected_bones = 0;
        time = 0;
        collected_secrets = 0;
		
		[score reset_multiplier];
		[score reset_score];
	}
    for (int i = 0; i < game_objects.count; i++) {
        GameObject *o = [game_objects objectAtIndex:i];
        [o reset];
    }
	
	if (challenge != NULL) {
		[UserInventory reset_to_equipped_gameitem];
	}
    
    [player reset];
    [self reset_camera];
    [GameControlImplementation reset_control_state];
	[self follow_player];
    current_mode = GameEngineLayerMode_GAMEPLAY;
}

-(void)check_falloff {
    if (![Common hitrect_touch:[self get_world_bounds] b:[player get_hit_rect]]) {
        [stats increment:GEStat_FALLING];
		[AudioManager playsfx:SFX_FAIL];
        [GEventDispatcher push_unique_event:[GEvent cons_type:GEventType_PLAYER_DIE]];
	}
}

-(void)frame_set_follow_clamp_y_min:(float)min max:(float)max {
	follow_clamp_y_max = -min;
	follow_clamp_y_min = -(max - [[CCDirector sharedDirector] winSize].height);
	actual_follow_clamp_y_max = max;
	actual_follow_clamp_y_min = min;
}

-(CGRange)get_follow_clamp_y_range {
	CGRange rtv;
	rtv.min = follow_clamp_y_min;
	rtv.max = follow_clamp_y_max;
	return rtv;
}
-(CGRange)get_actual_follow_clamp_y_range {
	CGRange rtv;
	rtv.min = actual_follow_clamp_y_min;
	rtv.max = actual_follow_clamp_y_max;
	return rtv;
}

-(void)reset_follow_clamp_y {
	follow_clamp_y_min = -INFINITY;
	follow_clamp_y_max = INFINITY;
	actual_follow_clamp_y_min = -INFINITY;
	actual_follow_clamp_y_max = INFINITY;
}

-(void)follow_player {
	[self follow_point:player.position];
}

-(void)follow_point:(CGPoint)pt {
	CGSize s = [[CCDirector sharedDirector] winSize];
	CGPoint halfScreenSize = ccp(s.width/2,s.height/2);
	[self setScale:_camera_z];
	[self setPosition:CGPointAdd(
	 ccp(
		 clampf(halfScreenSize.x-pt.x,-INFINITY,INFINITY) * [self scale],
		 clampf(halfScreenSize.y-pt.y,follow_clamp_y_min,follow_clamp_y_max) * [self scale]),
	 ccp(_camera_x,_camera_y + -500 * scrollup_pct ))];
}

//in transform self coords
-(void)set_layer_camera_x:(float)x y:(float)y z:(float)z {
	_camera_x = x;
	_camera_y = y;
	_camera_z = z;
}

//in transform self coords
-(CameraZoom)get_layer_camera {
	CameraZoom rtv = {_camera_x,_camera_y,_camera_z};
	return rtv;
}

-(void)incr_time:(float)t {
	time += t;
}

-(void)shake_for:(float)ct intensity:(float)intensity { //thx vlambeer
	shake_ct = ct;
	shake_intensity = intensity;
}

-(CGPoint)get_shake_offset {
	if (shake_ct <= 0) return CGPointZero;
	float t = float_random(-3.14, 3.14);
	Vec3D v = [VecLib scale:[VecLib cons_x:cosf(t) y:sinf(t) z:0] by:float_random(0,shake_intensity)];
	return ccp(v.x,v.y);
}

-(void)freeze_frame:(int)ct {
	[CCDirectorDisplayLink freeze_frame:ct];
}

-(void)update:(ccTime)delta {
	if (!first_update) {
		first_update = YES;
		[Resource unload_textures];
	}
	
	if (player.is_clockeffect && current_mode == GameEngineLayerMode_GAMEPLAY && [GameControlImplementation get_clockbutton_hold]) {
		[CCDirectorDisplayLink set_framemodct:4];
		[Common set_dt:delta/4];
	} else {
		[CCDirectorDisplayLink set_framemodct:1];
		[Common set_dt:delta];
	}
	
	if (shake_ct > 0) {
		shake_ct -= [Common get_dt_Scale];
		CGPoint shake = [self get_shake_offset];
		[self.parent setPosition:shake];
	} else {
		[self.parent setPosition:CGPointZero];
	}
	
	[self reset_follow_clamp_y];
	
    [GEventDispatcher dispatch_events];
    if (current_mode == GameEngineLayerMode_GAMEPLAY) {
		[self incr_time:[Common get_dt_Scale]];
		refresh_viewbox_cache = YES;
		[GameControlImplementation control_update_player:self];
		[GamePhysicsImplementation player_move:player with_islands:islands];
		[player update:self];
		[self check_falloff];
		[self update_gameobjs];
		[self update_particles];
		[self push_added_particles];
		[self update_render];
		[GameRenderImplementation update_render_on:self];
		[GEventDispatcher push_event:[GEvent cons_type:GEventType_GAME_TICK]];
		[self follow_player];
		
	} else if (current_mode == GameEngineLayerMode_CAPEOUT) {
		[self incr_time:[Common get_dt_Scale]];
		[player do_cape_anim];
		player.vx = 0;
		player.vy += 0.5*[Common get_dt_Scale];
		player.vy = MIN(20,player.vy);
		[player setPosition:CGPointAdd(player.position, ccp(player.vx,player.vy))];
		[self update_gameobjs];
		[self update_particles];
		[self push_added_particles];
		[GEventDispatcher push_event:[GEvent cons_type:GEventType_UIANIM_TICK]];
		
		Vec3D vdir_vec = [VecLib cons_x:10 y:player.vy z:0];
		[player setRotation:[VecLib get_rotation:vdir_vec offset:0]+180];
		
		runout_ct-=[Common get_dt_Scale];
		if (runout_ct <= 0) {
			[player reset_params];
			[[CCDirector sharedDirector] pushScene:[CapeGameEngineLayer scene_with_level:capegame_level_to_load?capegame_level_to_load:[CapeGameEngineLayer get_level]
																					   g:self
																					boss:do_boss_capegame]];
			capegame_level_to_load = NULL;
			
			if (do_boss_capegame) {
				[AudioManager playbgm_imm:BGM_GROUP_BOSS1];
				current_mode = GameEngineLayerMode_GAMEEND; //logic done in BOSS3_DEFEATED event
			} else {
				[AudioManager playbgm_imm:BGM_GROUP_CAPEGAME];
				current_mode = GameEngineLayerMode_CAPEIN_PRE_AD;
			}
			[Player character_bark];
			
			player.vy = 0;
			player.rotation = 0;
			[self cape_in_lock_on_tutorial_end];
			TutorialEnd *target_end = NULL;
			for (GameObject *o in game_objects) {
				if ([o class] == [TutorialEnd class]) {
					if (target_end == NULL) {
						target_end = (TutorialEnd*)o;
					} else if (o.position.x > player.position.x && o.position.x < target_end.position.x) {
						target_end = (TutorialEnd*)o;
					}
				}
			}
			if (target_end != NULL) {
				[self follow_point:target_end.position];
			}
			[self update_render];
		}
		
	} else if (current_mode == GameEngineLayerMode_CAPEIN_PRE_AD) {
		if (challenge == NULL) {
			current_mode = GameEngineLayerMode_SHOWING_AD;
			[AdColony_integration show_ad_onbegin:^{} onfinish:^{
				current_mode = GameEngineLayerMode_CAPEIN;
				[self play_worldnum_bgm];
				[[self get_ui_layer] show_cover:NO];
			}];
		} else {
			current_mode = GameEngineLayerMode_CAPEIN;
			[[self get_ui_layer] show_cover:NO];
		}
		[self update_render];
		
	} else if (current_mode == GameEngineLayerMode_CAPEIN) {
		if (do_runin_anim) {
			[self play_worldnum_bgm];
			do_runin_anim = NO;
		}
		
		[self incr_time:[Common get_dt_Scale]];
		[player do_stand_anim];
		[GamePhysicsImplementation player_move:player with_islands:islands];
		[self update_gameobjs];
		[self update_particles];
		[self push_added_particles];
		[GEventDispatcher push_event:[GEvent cons_type:GEventType_UIANIM_TICK]];
		
		if (player.current_island != NULL) { //when fall on the ground transition to normal gameplay (else lock the camera)
			current_mode = GameEngineLayerMode_GAMEPLAY;
		}
		
    } else if (current_mode == GameEngineLayerMode_UIANIM) {
        [GEventDispatcher push_event:[GEvent cons_type:GEventType_UIANIM_TICK]];
		[self follow_player];
        
    } else if (current_mode == GameEngineLayerMode_SCROLLDOWN) {
        [GEventDispatcher push_event:[GEvent cons_type:GEventType_GAME_TICK]];
        [GEventDispatcher push_event:[GEvent cons_type:GEventType_UIANIM_TICK]];
        scrollup_pct-=0.02*clampf([Common get_dt_Scale],0.8,1.3);
        if (scrollup_pct <= 0) {
            scrollup_pct = 0;
            if (do_runin_anim) {
                current_mode = GameEngineLayerMode_CAMERAFOLLOWTICK;
            } else {
                current_mode = GameEngineLayerMode_GAMEPLAY;
            }
        }
        [GEventDispatcher push_event:[[GEvent cons_type:GEventType_MENU_SCROLLBGUP_PCT] add_f1:scrollup_pct f2:0]];
		[self follow_player];
        
    } else if (current_mode == GameEngineLayerMode_CAMERAFOLLOWTICK) {
        [GEventDispatcher push_event:[GEvent cons_type:GEventType_UIANIM_TICK]];
        current_mode = GameEngineLayerMode_RUNINANIM;
		[self follow_player];
        [player setPosition:CGPointAdd(player.position, ccp(-300,0))];
        [player setVisible:YES];
        [player do_run_anim];
    
    } else if (current_mode == GameEngineLayerMode_RUNINANIM) {
        for (GameObject *i in game_objects) if ([i class] == [DogShadow class]) [i update:player g:self];
        [self update_particles];
        [self push_added_particles];
        if (player.position.x < player_starting_pos.x) {
            [GEventDispatcher push_event:[GEvent cons_type:GEventType_UIANIM_TICK]];
            [player setPosition:ccp(
				MIN(player_starting_pos.x,player.position.x+10*[Common get_dt_Scale]),
				player_starting_pos.y
			)];
        } else {
            player.position = ccp(player_starting_pos.x,player.position.y);
            [player do_stand_anim];
            [GEventDispatcher push_event:[GEvent cons_type:GEventType_START_INTIAL_ANIM]];
        }
        
    } else if (current_mode == GameEngineLayerMode_RUNOUT) {
        runout_ct--;
        if (runout_ct <= 0) {
            current_mode = GameEngineLayerMode_GAMEEND;
            [GEventDispatcher push_event:[GEvent cons_type:GEventType_LOAD_CHALLENGE_COMPLETE_MENU]];
        } else {        
            [GamePhysicsImplementation player_move:player with_islands:islands];
            [player update:self];
            [self update_gameobjs];
            [self update_particles];
            [self push_added_particles];
            [GEventDispatcher push_event:[GEvent cons_type:GEventType_UIANIM_TICK]];
        }
		
	} else if (current_mode == GameEngineLayerMode_RUNOUT_TO_FREEPUPS) {
        runout_ct--;
        if (runout_ct <= 0) {
            current_mode = GameEngineLayerMode_FADEOUT_TO_FREEPUPS;
        } else {
            [GamePhysicsImplementation player_move:player with_islands:islands];
            [player update:self];
            [self update_gameobjs];
            [self update_particles];
            [self push_added_particles];
            [GEventDispatcher push_event:[GEvent cons_type:GEventType_UIANIM_TICK]];
        }
		
    } else if (current_mode == GameEngineLayerMode_FADEOUT_TO_FREEPUPS) {
		CCLayerColor *fadeoutlayer = (CCLayerColor*)[self.parent getChildByTag:tFADEOUTLAYER];
		fadeoutlayer.opacity = fadeoutlayer.opacity + 15 > 255 ? 255 : fadeoutlayer.opacity + 15;
		
		if (fadeoutlayer.opacity >= 255) {
			current_mode = GameEngineLayerMode_GAMEEND;
			[[CCDirector sharedDirector] pushScene:[FreePupsAnim scene_with:world_mode.cur_world g:self]];
			[AudioManager bgm_stop];
			[GameControlImplementation reset_control_state];
			[Common unset_dt];
		}
		
	} else if (current_mode == GameEngineLayerMode_SHOWING_AD) {
		[self incr_time:[Common get_dt_Scale]];
	}
    [GEventDispatcher dispatch_events];
}

#define ONEUP_EVERY 100
-(void)collect_bone:(BOOL)do_1up_anim {
	collected_bones++;
	if (challenge == NULL && (collected_bones%ONEUP_EVERY==0 ||
			([Player current_character_has_power:CharacterPower_DOUBLELIVES] && collected_bones%(ONEUP_EVERY/2)==0))) {
		[AudioManager playsfx:SFX_1UP];
		if (do_1up_anim) [[self get_ui_layer] start_oneup_anim];
		
		[self incr_lives];
	}
	[UserInventory add_bones:1];
}

-(GameEngineLayerMode)get_mode {
	return current_mode;
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_QUIT) {
        if ([self get_challenge] == NULL) {
			[TrackingUtil track_evt:TrackingEvt_GameEnd
							   val1:[stats get_disp_str_for_stat:GEStat_BONES_COLLECTED g:self]
							   val2:[stats get_disp_str_for_stat:GEStat_DEATHS g:self]
							   val3:[NSString stringWithFormat:@"START(%@)_DO(%@)",
									 [FreeRunStartAtManager name_for_loc:[FreeRunStartAtManager get_starting_loc]],
									 [stats get_disp_str_for_stat:GEStat_SECTIONS g:self]]];
		}
		
		[self exit];
		[GEventDispatcher remove_all_listeners];
        [GameMain start_menu];
        
    } else if (e.type == GEventType_RETRY_WITH_CALLBACK) {
        [self exit];
        GameModeCallback *cb = [e get_value:@"callback"];
		if (cb == NULL) {
			NSLog(@"retry cb is null!");
		} else {
			[cb run];
		}
    
    } else if (e.type == GEventType_PLAYAGAIN_AUTOLEVEL) {
        [self exit];
        [GameMain start_game_autolevel];
        
    } else if (e.type == GEventType_CHECKPOINT) {
        [self set_checkpoint_to:e.pt];
        
    } else if (e.type == GEventType_COLLECT_BONE) {
		[self collect_bone:YES];
		
	} else if (e.type == GEventType_GET_COIN) {
		[UserInventory add_coins:1];
    
    } else if (e.type == GEventType_GET_TREAT) {
        collected_secrets++;
    
    } else if (e.type == GEventType_CHALLENGE_COMPLETE) {
		if ([self get_challenge].type != ChallengeType_BOSSRUSH) {
			runout_ct = 100;
			current_mode = GameEngineLayerMode_RUNOUT;
		}
        
    } else if (e.type == GEventType_PAUSE) {
		if (current_mode == GameEngineLayerMode_GAMEPLAY) {
			stored_mode = current_mode;
			current_mode = GameEngineLayerMode_PAUSED;
			[CCDirectorDisplayLink set_framemodct:1];
			[[self get_ui_layer] pause_action];
			
		} else if (current_mode == GameEngineLayerMode_PAUSED) {
			[GEventDispatcher push_event:[GEvent cons_type:GEventType_UNPAUSE]];
			
		}
        
    } else if (e.type == GEventType_UNPAUSE) {
		if (current_mode == GameEngineLayerMode_PAUSED) {
			current_mode = stored_mode;
			[[self get_ui_layer] unpause_action];
		}
        
    } else if (e.type == GEventType_PLAYER_DIE) {
        [stats increment:GEStat_DEATHS];
		
        lives = lives == GAMEENGINE_INF_LIVES ? lives : lives-1;
		[score decrement_score:1000];
		
        if (lives != GAMEENGINE_INF_LIVES && lives < 1) {
            [self ask_continue];
        } else {
            [self player_reset];
            [player add_effect:[FlashEffect cons_from:[player get_current_params] time:35]];
        }
        
    } else if (e.type == GEventType_CONTINUE_GAME) {
        lives = default_starting_lives;
        [self player_reset];
        [player add_effect:[FlashEffect cons_from:[player get_current_params] time:35]];
        
    } else if (e.type == GEventType_ENTER_LABAREA) {
		world_mode.cur_mode = BGMode_LAB;
		[AudioManager playbgm_imm:BGM_GROUP_LAB];
		
	} else if (e.type == GEventType_BEGIN_CAPE_GAME) {
		if ([player is_armored]) {
			[player end_armored];
			[player update:self];
		}
		if ([e get_value:@"map"]) {
			capegame_level_to_load = [e get_value:@"map"];
		} else {
			capegame_level_to_load = NULL;
		}
		current_mode = GameEngineLayerMode_CAPEOUT;
		[player reset_params];
		[GameControlImplementation reset_control_state];
		runout_ct = 100;
		player.current_island = NULL;
		do_boss_capegame = NO;
		
	} else if (e.type == GEventType_BEGIN_BOSS_CAPE_GAME) {
		if ([player is_armored]) {
			[player end_armored];
			[player update:self];
		}
		current_mode = GameEngineLayerMode_CAPEOUT;
		[player reset_params];
		[GameControlImplementation reset_control_state];
		runout_ct = 100;
		player.current_island = NULL;
		do_boss_capegame = YES;
		
	} else if (e.type == GEventType_BOSS1_DEFEATED || e.type == GEventType_BOSS2_DEFEATED) {
		if ([self get_challenge] == NULL) {
			current_mode = GameEngineLayerMode_RUNOUT_TO_FREEPUPS;
			runout_ct = 100;
		}
		
	} else if (e.type == GEventType_BOSS3_DEFEATED) {
		CCLayerColor *fadeoutlayer = (CCLayerColor*)[self.parent getChildByTag:tFADEOUTLAYER];
		fadeoutlayer.opacity = 255;
		[[CCDirector sharedDirector] pushScene:[CapeGameEngineLayer credits_scene_g:self]];
		[AudioManager playbgm_imm:BGM_GROUP_WORLD1];
		[Player character_bark];
		
	} else if (e.type == GEventType_BOSS3_CREDITS_END) {
		if ([self get_challenge] == NULL) {
			current_mode = GameEngineLayerMode_FADEOUT_TO_FREEPUPS;
		} else {
            current_mode = GameEngineLayerMode_GAMEEND;
			
			[GEventDispatcher immediate_event:
			 [[[GEvent cons_type:GEventType_CHALLENGE_COMPLETE]
			   add_i1:1 i2:0]
			  add_key:@"challenge" value:[self get_challenge]]
			 ];
			
            [GEventDispatcher push_event:[GEvent cons_type:GEventType_LOAD_CHALLENGE_COMPLETE_MENU]];
			
			CCLayerColor *fadeoutlayer = (CCLayerColor*)[self.parent getChildByTag:tFADEOUTLAYER];
			[fadeoutlayer setOpacity:0];
		}
		
	}
}

-(void)exit_to_next_world {
	current_mode = GameEngineLayerMode_GAMEEND;
	[FreeRunStartAtManager set_starting_loc:[world_mode get_next_world_startat]];
	
	[self exit];
	[GameMain start_game_autolevel];
}

-(void)update_gameobjs {
    for(int i = (int)[game_objects count]-1; i>=0 ; i--) {
        GameObject *o = [game_objects objectAtIndex:i];
        [o update:player g:self];
		
    }
	[self do_remove_gameobjects];
}

-(void)add_gameobject:(GameObject*)o {
    [game_objects addObject:o];
    [self addChild:o z:[o get_render_ord]];
}
-(void)remove_gameobject:(GameObject *)o {
	[gameobjects_tbr addObject:o];
}

-(void)do_remove_gameobjects {
	for (GameObject *o in gameobjects_tbr) {
		[game_objects removeObject:o];
		[self removeChild:o cleanup:YES];
	}
	[gameobjects_tbr removeAllObjects];
}

-(void)ask_continue {
    current_mode = GameEngineLayerMode_GAMEEND;
    [GEventDispatcher push_event:[GEvent cons_type:GEventType_ASK_CONTINUE]];
}
-(void)exit {
    [self unscheduleAllSelectors];
	[ScoreManager set_world:world_mode.cur_world highscore:[score get_score]];
	
	for (GameObject *o in game_objects) {
		if ([[o class] isSubclassOfClass:[AutoLevel class]]) [(AutoLevel*)o game_quit];
	}
	
	for (int i = (int)islands.count-1; i>= 0; i--) {
		Island *o = islands[i];
		[o repool];
		[self removeChild:o cleanup:YES];
	}
	[islands removeAllObjects];
	
	for (int i = (int)game_objects.count -1; i >= 0; i--) {
		GameObject *o = game_objects[i];
		[o repool];
		[self removeChild:o cleanup:YES];
	}
	[game_objects removeAllObjects];
	
	for (int i = (int)particles.count -1; i >= 0; i--) {
		Particle *p = particles[i];
		[p repool];
		[particle_holder removeChild:p cleanup:YES];
		//[self removeChild:p cleanup:YES];
	}
	[particles removeAllObjects];
	[self removeChild:player cleanup:YES];
	
    [GEventDispatcher remove_all_listeners];
    [[CCDirector sharedDirector] resume];
    [BatchDraw clear];
	
	[[self parent] removeAllChildrenWithCleanup:YES];
}


-(void)reset_camera {
    [GameRenderImplementation reset_camera:&camera_state];
    [GameRenderImplementation reset_camera:&tar_camera_state];
    [GameRenderImplementation update_camera_on:self zoom:camera_state];
}
-(void)set_target_camera:(CameraZoom)tar {
    tar_camera_state = tar;
}
-(void)set_camera:(CameraZoom)tar {
    camera_state = tar;
}

-(void)set_checkpoint_to:(CGPoint)pt {
    player.start_pt = pt;
}

-(void)addChild:(CCNode *)node z:(NSInteger)z {
    refresh_worldbounds_cache = YES;
    [super addChild:node z:z];
}
-(void)setColor:(ccColor3B)color {
	for(CCSprite *sprite in islands) {
        [sprite setColor:color];
	}
    for(CCSprite *sprite in game_objects) {
        [sprite setColor:color];
    }
    [player setColor:color];
}

-(HitRect) get_world_bounds {
    if (refresh_worldbounds_cache) {
        refresh_worldbounds_cache = NO;
        float min_x = 5000;
        float min_y = 5000;
        float max_x = -5000;
        float max_y = -5000;
        for (Island* i in islands) {
            max_x = MAX(MAX(max_x, i.endX),i.startX);
            max_y = MAX(MAX(max_y, i.endY),i.startY);
            min_x = MIN(MIN(min_x, i.endX),i.startX);
            min_y = MIN(MIN(min_y, i.endY),i.startY);
        }
        for(GameObject* o in game_objects) {
			
            max_x = MAX(max_x, o.position.x);
            max_y = MAX(max_y, o.position.y);
            min_x = MIN(min_x, o.position.x);
            min_y = MIN(min_y, o.position.y);
        }
		
        HitRect r = [Common hitrect_cons_x1:min_x y1:min_y-200 x2:max_x+1000 y2:max_y+2000];
        cached_worldsbounds = r;
    }
    return cached_worldsbounds;
}
-(HitRect)get_viewbox {
    if (current_mode == GameEngineLayerMode_SCROLLDOWN || current_mode == GameEngineLayerMode_RUNINANIM || current_mode == GameEngineLayerMode_CAPEIN) {
        return [Common hitrect_cons_x1:player.position.x-1500 y1:player.position.y-2500 wid:4000 hei:4000];
    }
    
    if (refresh_viewbox_cache) {
        refresh_viewbox_cache = NO;
        cached_viewbox = [Common hitrect_cons_x1:(-self.position.x-[Common SCREEN].width*1.5)*1/[self scaleX]
                                              y1:(-self.position.y-[Common SCREEN].height*1.5)*1/[self scaleY]
                                             wid:[Common SCREEN].width*4.5*1/[self scaleX]
                                             hei:[Common SCREEN].height*4.5*1/[self scaleX]];
    }
    return cached_viewbox;
}
-(int)get_lives { return lives; }
-(int)get_time { return time; }
-(int)get_num_bones { return collected_bones; }
-(int)get_num_secrets { return collected_secrets; }

-(int)get_current_continue_cost {return current_continue_cost;}
-(void)incr_current_continue_cost { current_continue_cost+=1; }


-(void)add_particle:(Particle*)p {
    [particles_tba addObject:p];
}
-(int)get_num_particles {
    return (int)[particles count];
}
-(void)push_added_particles {
    for (Particle *p in particles_tba) {
        [particles addObject:p];
        [particle_holder addChild:p z:[p get_render_ord]];
    }
    [particles_tba removeAllObjects];
}
-(void)update_particles {
    NSMutableArray *toremove = [NSMutableArray array];
    for (Particle *i in particles) {
        [i update:self];
        if ([i should_remove]) {
			[particle_holder removeChild:i cleanup:YES];
            [toremove addObject:i];
			[i repool];
        }
    }
    [particles removeObjectsInArray:toremove];
}

static bool _began_hold_clockbutton = NO;
-(void) ccTouchesBegan:(NSSet*)pTouches withEvent:(UIEvent*)pEvent {
    if (current_mode != GameEngineLayerMode_GAMEPLAY) return;
	
	UITouch *t = [[pTouches allObjects] objectAtIndex:0];
	CGPoint touch = [t locationInView:[t view]];
	
	if (player.is_clockeffect) {
		CGPoint yflipped_touch = ccp(touch.x,[Common SCREEN].height-touch.y);
		CGPoint touch_corner = [Common screen_pctwid:0.82 pcthei:0.09];
		touch_corner.y += 40;
		touch_corner.x -= 20;
		if (yflipped_touch.x > touch_corner.x && yflipped_touch.y < touch_corner.y) {
			_began_hold_clockbutton = YES;
		} else {
			_began_hold_clockbutton = NO;
		}
	} else {
		_began_hold_clockbutton = NO;
	}
	
	if (!_began_hold_clockbutton) [GameControlImplementation touch_begin:touch];
	
}
-(void) ccTouchesMoved:(NSSet *)pTouches withEvent:(UIEvent *)event {
    if (current_mode != GameEngineLayerMode_GAMEPLAY) return;
    
    UITouch *t = [[pTouches allObjects] objectAtIndex:0];
	CGPoint touch = [t locationInView:[t view]];
	
	if (!_began_hold_clockbutton) [GameControlImplementation touch_move:touch];
}
-(void) ccTouchesEnded:(NSSet*)pTouches withEvent:(UIEvent*)event {
    if (current_mode != GameEngineLayerMode_GAMEPLAY) return;
    
    UITouch *t = [[pTouches allObjects] objectAtIndex:0];
	CGPoint touch = [t locationInView:[t view]];
	
	if (!_began_hold_clockbutton) [GameControlImplementation touch_end:touch];
	
	if (_began_hold_clockbutton) [GameControlImplementation set_clockbutton_hold:![GameControlImplementation get_clockbutton_hold]];
	_began_hold_clockbutton = NO;
	
    
}

-(void)draw {
    [super draw];
    
    if (![GameMain GET_DRAW_HITBOX]) {
        return;
    }
    //glColor4ub(255,0,0,100);
    glLineWidth(1.0f);
    HitRect re = [player get_hit_rect]; 
    CGPoint *verts = [Common hitrect_get_pts:re];
    ccDrawPoly(verts, 4, YES);
    
    if (player.current_island == NULL) {
        CGPoint a = ccp(verts[2].x,verts[2].y);
        Vec3D dv = [VecLib cons_x:player.vx y:player.vy z:0];
        [VecLib normalize:dv];
        [VecLib scale:dv by:50];
        CGPoint b = ccp(a.x+dv.x,a.y+dv.y);
        ccDrawLine(a, b);
    }
    free(verts);
    
    for (GameObject* o in game_objects) {
        HitRect pathBox = [o get_hit_rect];
        verts = [Common hitrect_get_pts:pathBox];
        ccDrawPoly(verts, 4, YES);
        free(verts);
    }
    
    HitRect viewbox = [self get_viewbox];
    verts = [Common hitrect_get_pts:viewbox];
    ccDrawPoly(verts, 4, YES);
    free(verts);
 }

-(void)incr_lives {
	if (lives != GAMEENGINE_INF_LIVES) {
		[Player character_bark];
		lives = lives + 1;
	}
}

-(BGLayer*)get_bg_layer {
	return (BGLayer*)[[self parent] getChildByTag:tBGLAYER];
}

-(void)cape_in_lock_on_tutorial_end {
	TutorialEnd *target_end = NULL;
	for (GameObject *o in game_objects) {
		if ([o class] == [TutorialEnd class]) {
			if (target_end == NULL) {
				target_end = (TutorialEnd*)o;
			} else if (o.position.x > player.position.x && o.position.x < target_end.position.x) {
				target_end = (TutorialEnd*)o;
			}
		}
	}
	if (target_end != NULL) {
		player.position = ccp(target_end.position.x,target_end.position.y+600);
		CGSize s = [[CCDirector sharedDirector] winSize];
		CGPoint halfScreenSize = ccp(s.width/2,s.height/2);
		[self setPosition:ccp(
							  clampf(halfScreenSize.x-player.position.x,-INFINITY,INFINITY),
							  clampf(halfScreenSize.y-target_end.position.y,follow_clamp_y_min,follow_clamp_y_max)
							  )];
		refresh_viewbox_cache = YES;
		[self update_render];
		do_runin_anim = YES;
		
	}
}

-(void)dealloc {
    [self removeAllChildrenWithCleanup:YES];
    [islands removeAllObjects];
    [game_objects removeAllObjects];
    [particles removeAllObjects];
}

-(GameEngineLayer*)set_bones:(int)b {
	collected_bones = b;
	return self;
}

-(GameEngineLayer*)set_time:(int)t {
	time = t;
	return self;
}

-(GameEngineLayer*)copy_stats:(GameEngineStats*)copy_stats {
	[stats copy_stats:copy_stats];
	return self;
}


@end

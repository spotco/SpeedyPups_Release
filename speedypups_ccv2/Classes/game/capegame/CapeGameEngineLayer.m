#import "CapeGameEngineLayer.h"
#import "Resource.h"
#import "FileCache.h"
#import "BackgroundObject.h"
#import "CapeGamePlayer.h"
#import "CapeGameUILayer.h"
#import "GameEngineLayer.h"
#import "UICommon.h"
#import "Common.h"
#import "FireworksParticleA.h"
#import "CapeGameEngineLayer_CreditsScene.h"
#import "UILayer.h"

#import "CapeGameBossCat.h"

#import "OneUpParticle.h"
#import "DazedParticle.h"

@implementation CapeGameObject
-(void)update:(CapeGameEngineLayer*)g{}
@end

@implementation CapeGameEngineLayer {
	BOOL pause;
}
@synthesize is_boss_capegame;

static int lvl_ct = 0;
static NSString *blank = @"";
+(NSString*)get_level {
	
	NSString *rtv = blank;
	
	if (lvl_ct%3==0) {
		rtv = @"capegame_easy";
	} else if (lvl_ct%3==1) {
		rtv = @"capegame_creative";
	} else if (lvl_ct%3==2) {
		rtv = @"capegame_test";
	}
	lvl_ct++;
	//return @"shittytest";
	return rtv;
}

+(CCScene*)scene_with_level:(NSString *)file g:(GameEngineLayer *)g boss:(BOOL)boss {
	CCScene *scene = [CCScene node];
	[scene addChild:[[CapeGameEngineLayer node] cons_with_level:file g:g boss:boss]];
	return scene;
}

+(CCScene*)credits_scene_g:(GameEngineLayer*)g {
	CCScene *scene = [CCScene node];
	[scene addChild:[[CapeGameEngineLayer node] cons_credits_scene:g]];
	return scene;
}

#define GAME_DURATION 2100.0
#define BOSS_INFINITE_DURATION 9999
#define START_TARPOS [Common screen_pctwid:0.2 pcthei:0.5]
#define END_TARPOS [Common screen_pctwid:0.2 pcthei:-0.4]

-(NSMutableArray*)get_gameobjs {
	return game_objects;
}

-(id)cons_with_level:(NSString*)file g:(GameEngineLayer*)g boss:(BOOL)boss {
	is_boss_capegame = boss;
	main_game = g;
	is_credits_scene = NO;
	pause = NO;
	[GEventDispatcher add_listener:self];
	
	bg = [BackgroundObject backgroundFromTex:[Resource get_tex:is_boss_capegame?TEX_CLOUDGAME_BOSS_BG:TEX_CLOUDGAME_BG] scrollspd_x:0.1 scrollspd_y:0];
	if (!boss)[Common scale_to_fit_screen_x:bg];
	[Common scale_to_fit_screen_y:bg];
	[self addChild:bg];
	
	
	bgclouds = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_CLOUDGAME_BGCLOUDS] scrollspd_x:0.1 scrollspd_y:0];
	if (!is_boss_capegame) [self addChild:bgclouds];
	
	if (is_boss_capegame) {
		thunder_bg = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_CLOUDGAME_BOSS_BG_THUNDER] scrollspd_x:0.1 scrollspd_y:0];
		[Common scale_to_fit_screen_y:thunder_bg];
		[self addChild:thunder_bg];
		thunder_bg.opacity = 0;
	};
	
	
	player = [CapeGamePlayer cons];
	[player setPosition:END_TARPOS];
	[self addChild:player z:2];
	
	
	top_scroll = [CCSprite spriteWithTexture:[Resource get_tex:is_boss_capegame?TEX_CLOUDGAME_BOSS_CLOUDFLOOR:TEX_CLOUDGAME_CLOUDFLOOR]];
	[top_scroll setScaleX:[Common scale_from_default].x];
	[top_scroll setScaleY:-[Common scale_from_default].x];
	[top_scroll setPosition:[Common screen_pctwid:0 pcthei:1]];
	bottom_scroll = [CCSprite spriteWithTexture:[Resource get_tex:is_boss_capegame?TEX_CLOUDGAME_BOSS_CLOUDFLOOR:TEX_CLOUDGAME_CLOUDFLOOR]];
	[bottom_scroll setScaleX:[Common scale_from_default].x];
	[bottom_scroll setScaleY:[Common scale_from_default].x];
	
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE};
	[[top_scroll texture] setTexParameters:&par];
	[[bottom_scroll texture] setTexParameters:&par];
	
	[top_scroll setAnchorPoint:ccp(0,0)];
	[bottom_scroll setAnchorPoint:ccp(0,0)];
	[top_scroll setOpacity:220];
	[bottom_scroll setOpacity:220];
	[self addChild:top_scroll z:3];
	[self addChild:bottom_scroll z:3];
	
	particleholder = [CCSprite node];
	[self addChild:particleholder z:5];
	particles = [NSMutableArray array];
	particles_tba = [NSMutableArray array];
	
	game_objects = [NSMutableArray array];
	if (is_boss_capegame) {
		[self add_gameobject:[CapeGameBossCat cons]];
		duration = BOSS_INFINITE_DURATION;
		
	} else {
		if ([main_game get_challenge]) {
			[MapLoader set_maploader_mode:MapLoaderMode_CHALLENGE];
		}
		GameMap *map = [MapLoader load_capegame_map:file];
		[MapLoader set_maploader_mode:MapLoaderMode_AUTO];
		for (CapeGameObject *o in map.game_objects) {
			[self add_gameobject:o];
		}
		[map.game_objects removeAllObjects];
		duration = GAME_DURATION;
	}
	
	ui = [CapeGameUILayer cons_g:self];
	[self addChild:ui z:6];
	
	
	self.isTouchEnabled = YES;
	[self schedule:@selector(update:)];
	
	touch_down = NO;
	initial_hold = YES;
	
	current_mode = CapeGameMode_FALLIN;
	gameobjects_tbr = [NSMutableArray array];
	
	count_as_death = NO;
	gameend_constant_speed = 0;
	
	return self;
}

-(void)dispatch_event:(GEvent *)e {
	if (e.type == GEventType_PAUSE) {
		if (!pause) {
			[[self get_ui] pause];
		} else {
			[GEventDispatcher push_event:[GEvent cons_type:GEventType_UNPAUSE]];
		}
	} else if (e.type == GEventType_UNPAUSE) {
		[[self get_ui] unpause];
	}
}

-(CapeGamePlayer*)player {
	return player;
}

-(void)add_particle:(Particle*)p {
	[particles_tba addObject:p];
}

-(void)push_added_particles {
    for (Particle *p in particles_tba) {
        [particles addObject:p];
        [particleholder addChild:p z:[p get_render_ord]];
    }
    [particles_tba removeAllObjects];
}

-(void)add_gameobject:(CapeGameObject*)o {
    [game_objects addObject:o];
    [self addChild:o];
}

-(void)remove_gameobject:(CapeGameObject*)o {
	[gameobjects_tbr addObject:o];
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
	[[self get_main_game] freeze_frame:ct];
}

-(void)update:(ccTime)dt {
	[Common set_dt:dt];
	[GEventDispatcher dispatch_events];
	if (pause) return;
	if (shake_ct > 0) {
		shake_ct -= [Common get_dt_Scale];
		CGPoint shake = [self get_shake_offset];
		[self.parent setPosition:shake];
	} else {
		[self.parent setPosition:CGPointZero];
	}
	
	[player update:self];
	[main_game incr_time:[Common get_dt_Scale]];
	[ui update];
	if (![self is_boss_capegame])[ui update_pct:duration/GAME_DURATION];
	[[ui bones_disp] set_label:strf("%i",[main_game get_num_bones])];
	[[ui lives_disp] set_label:strf("\u00B7 %s",[main_game get_lives] == GAMEENGINE_INF_LIVES ? "\u221E":strf("%i",[main_game get_lives]).UTF8String)];
	[[ui time_disp] set_label:[UICommon parse_gameengine_time:[main_game get_time]]];
	
	if (is_boss_capegame) {
		if (thunder_bg != NULL) {
			thunder_flash_ct-=[Common get_dt_Scale];
			thunder_bg.opacity*=0.9;
			if (thunder_flash_ct <= 0) {
				[thunder_bg setOpacity:255];
				thunder_flash_ct = 800;
				[AudioManager playsfx:SFX_THUNDER];
			}
		}
		
	} else if (is_credits_scene) {
		[self credits_update];
	}
	
	[self push_added_particles];
    NSMutableArray *toremove = [NSMutableArray array];
    for (Particle *i in particles) {
        [i update:(id)self]; //don't do this at home
        if ([i should_remove]) {
            [particleholder removeChild:i cleanup:YES];
            [toremove addObject:i];
			[i repool];
        }
    }
    [particles removeObjectsInArray:toremove];
	
	for (CapeGameObject *o in gameobjects_tbr) {
		[game_objects removeObject:o];
		[self removeChild:o cleanup:YES];
	}
	[gameobjects_tbr removeAllObjects];
	
	if (current_mode == CapeGameMode_FALLIN) {
		CGPoint tar = START_TARPOS;
		CGPoint last_pos = player.position;
		CGPoint neu_pos = ccp(
							  last_pos.x + (tar.x - last_pos.x)/10.0,
							  last_pos.y + (tar.y - last_pos.y)/10.0
							  );
		player.vy = neu_pos.y - last_pos.y;
		[player set_rotation];
		[player setPosition:neu_pos];
		if (CGPointDist(neu_pos, tar) < 1) {
			[player setPosition:tar];
			player.vy = 0;
			current_mode = CapeGameMode_GAMEPLAY;
		}
		return;
	} else if (current_mode == CapeGameMode_FALLOUT) {
		CGPoint tar = END_TARPOS;
		player.vy -= 0.3;
		[player setPosition:CGPointAdd(player.position, ccp(player.vx,player.vy))];
		if (player.position.y < tar.y) {
			[self exit];
			[AudioManager playsfx:SFX_FAIL];
			if (count_as_death) {
				[GEventDispatcher push_unique_event:[GEvent cons_type:GEventType_PLAYER_DIE]];
			} else if (is_credits_scene) {
				[GEventDispatcher immediate_event:[GEvent cons_type:GEventType_BOSS3_CREDITS_END]];
			}
		}
		return;
		
	} else if (current_mode == CapeGameMode_BOSS3_DEFEATED_FLYOUT) { //credits scene
		[player setPosition:CGPointAdd(player.position, ccp(7*[Common get_dt_Scale],0))];
		[player setRotation:0];
		if (player.position.x > [Common SCREEN].width * 1.2) {
			[AudioManager playsfx:SFX_POWERUP];
			[self exit];
			[GEventDispatcher immediate_event:[GEvent cons_type:GEventType_BOSS3_DEFEATED]];
		}
		return;
	}
	
	
	if ([self is_boss_capegame]) {
		if ([player is_rocket]) {
			[ui itembar_set_visible:YES];
			float total_dist = ([Common SCREEN].width*1.1-START_TARPOS.x) + 50 + START_TARPOS.x;
			[ui update_pct:1-(behind_catchup?
							  (([Common SCREEN].width*1.1-START_TARPOS.x) + 50 + player.position.x)/total_dist:
							  (player.position.x-START_TARPOS.x)/total_dist)];
			
			if (!behind_catchup) {
				player.position = ccp(player.position.x+[Common get_dt_Scale] * 4,player.position.y);
				if (player.position.x > [Common SCREEN].width*1.1) {
					player.position = ccp(-50,player.position.y);
					behind_catchup = YES;
				}
			} else {
				if (player.position.x < START_TARPOS.x) {
					player.position = ccp(player.position.x+[Common get_dt_Scale]*4,player.position.y);
				} else {
					player.position = ccp(START_TARPOS.x,player.position.y);
					behind_catchup = NO;
					[player do_cape_anim];
					[AudioManager playsfx:SFX_POWERDOWN];
				}
				
			}
			
		} else {
			[ui itembar_set_visible:NO];
		}
		
	}
	
	
	float speed = gameend_constant_speed != 0 ? gameend_constant_speed :
	(is_boss_capegame || is_credits_scene ? 7 : (1-duration/GAME_DURATION)*6 + 4);
	
	bgclouds_scroll_x += speed;
	[bgclouds update_posx:bgclouds_scroll_x posy:0];
	if (is_boss_capegame) {
		[thunder_bg update_posx:bgclouds_scroll_x posy:0];
		[bg update_posx:bgclouds_scroll_x posy:0];
	}
	
	CGRect scroll_rect = top_scroll.textureRect;
	scroll_rect.origin.x += speed/2;
	scroll_rect.origin.x = ((int)(scroll_rect.origin.x))%top_scroll.texture.pixelsWide + ((scroll_rect.origin.x) - ((int)(scroll_rect.origin.x)));
	[top_scroll setTextureRect:scroll_rect];
	[bottom_scroll setTextureRect:scroll_rect];
	
	if (touch_down) {
		player.vy = MIN(player.vy + 1.6, 7);
		if (!last_touch_down) [AudioManager playsfx:SFX_CAPE_UP];
	} else if (initial_hold) {
		player.vy = MAX(player.vy - 0.005,-7);
	} else {
		player.vy = MAX(player.vy - 0.35,-7);
	}
	last_touch_down = touch_down;
	
	CGPoint neupos = CGPointAdd(player.position, ccp(0,player.vy));
	neupos.y = clampf(neupos.y, [Common SCREEN].height*0.1, [Common SCREEN].height*0.9);
	player.position = neupos;
	[player set_rotation];
	
	for (int i = (int)game_objects.count-1; i >= 0; i--) {
		CapeGameObject *o = game_objects[i];
		[o setPosition:CGPointAdd(ccp(-speed,0), o.position)];
		[o update:self];
	}
	
	if (duration != BOSS_INFINITE_DURATION) duration--;
	if (duration <= 0) {
		[player do_stand];
		current_mode = CapeGameMode_FALLOUT;
	}
}

-(void)duration_end {
	gameend_constant_speed = (1-duration/GAME_DURATION)*6 + 4;
	duration = 10;
	
	DO_FOR(9,
		   [self add_particle:[FireworksParticleA cons_x:player.position.x + float_random((i+1)*80-50, (i+1)*80+50)
													   y:0
													  vx:0
													  vy:float_random(6,14)
													  ct:int_random(4, 25)]];
		   );
	
	
}

-(GameEngineLayer*)get_main_game {
	return main_game;
}

-(void)do_get_hit {
	count_as_death = self.is_boss_capegame;
	[player do_hit];
	current_mode = CapeGameMode_FALLOUT;
	[DazedParticle cons_effect:self sprite:player time:40];
}

-(void)boss_end {
	count_as_death = NO;
	current_mode = CapeGameMode_BOSS3_DEFEATED_FLYOUT;
}

-(void)credits_end {
	[player do_stand];
	count_as_death = NO;
	current_mode = CapeGameMode_FALLOUT;
}

-(void)do_powerup_rocket {
	[player do_rocket];
}

-(void)collect_bone:(CGPoint)screen_pos {
	[main_game collect_bone:NO];
	[ui do_bone_collect_anim:screen_pos];
	
	if ([main_game get_challenge]==NULL && [main_game get_num_bones]%100==0) {
		OneUpParticle *p = [OneUpParticle cons_pt:player.position];
		[p csf_setScale:0.4];
		[self add_particle:p];
		[AudioManager playsfx:SFX_1UP];
	}
}

-(CapeGameUILayer*)get_ui {
	return ui;
}

-(void)do_tutorial_anim {
	[ui do_tutorial_anim];
}

-(void) ccTouchesBegan:(NSSet*)pTouches withEvent:(UIEvent*)pEvent {
    CGPoint touch;
    for (UITouch *t in pTouches) {
        touch = [t locationInView:[t view]];
    }
	touch_down = YES;
	initial_hold = NO;
}
-(void) ccTouchesMoved:(NSSet *)pTouches withEvent:(UIEvent *)event {
    CGPoint touch;
    for (UITouch *t in pTouches) {
        touch = [t locationInView:[t view]];
    }
}
-(void) ccTouchesEnded:(NSSet*)pTouches withEvent:(UIEvent*)event {
    CGPoint touch;
    for (UITouch *t in pTouches) {
        touch = [t locationInView:[t view]];
    }
	touch_down = NO;
}

-(void)pause:(BOOL)do_pause {
	pause = do_pause;
}

-(void)exit {
	[[[self get_main_game] get_ui_layer] show_cover:YES];
	[GEventDispatcher remove_listener:self];
	[self removeAllChildrenWithCleanup:YES];
	for (Particle *p in particles) {
		[particleholder removeChild:p cleanup:YES];
		[p repool];
	}
	[particles removeAllObjects];
	[ui exit];
	[[CCDirector sharedDirector] popScene];
}

@end

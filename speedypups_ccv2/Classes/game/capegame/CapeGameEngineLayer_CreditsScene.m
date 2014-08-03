#import "CapeGameEngineLayer_CreditsScene.h"
#import "BackgroundObject.h"
#import "Common.h"
#import "Resource.h" 
#import "FileCache.h"
#import "CapeGamePlayer.h"
#import "CapeGameUILayer.h"
#import "CreditsFlybyObject.h"
#import "CapeGameBone.h"
#import "Player.h"

@implementation CapeGameEngineLayer (CapeGameEngineLayer_CreditsScene)

#define BOSS_INFINITE_DURATION 9999
#define END_TARPOS [Common screen_pctwid:-0.2 pcthei:0.5]

-(id)cons_credits_scene:(GameEngineLayer*)g {
	self.is_boss_capegame = NO;
	main_game = g;
	is_credits_scene = YES;
	
	bg = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_CLOUDGAME_BG] scrollspd_x:0.1 scrollspd_y:0];
	[Common scale_to_fit_screen_x:bg];
	[Common scale_to_fit_screen_y:bg];
	[self addChild:bg];
	
	bgclouds = [BackgroundObject backgroundFromTex:[Resource get_tex:TEX_CLOUDGAME_BGCLOUDS] scrollspd_x:0.1 scrollspd_y:0];
	[self addChild:bgclouds];
	
	player = [CapeGamePlayer cons];
	[player setPosition:END_TARPOS];
	[self addChild:player z:2];
	
	
	top_scroll = [CCSprite spriteWithTexture:[Resource get_tex:TEX_CLOUDGAME_CLOUDFLOOR]];
	[top_scroll setScaleX:[Common scale_from_default].x];
	[top_scroll setScaleY:-[Common scale_from_default].x];
	[top_scroll setPosition:[Common screen_pctwid:0 pcthei:1]];
	bottom_scroll = [CCSprite spriteWithTexture:[Resource get_tex:TEX_CLOUDGAME_CLOUDFLOOR]];
	[bottom_scroll setScaleX:[Common scale_from_default].x];
	[bottom_scroll setScaleY:[Common scale_from_default].y];
	[top_scroll setAnchorPoint:ccp(0,0)];
	[bottom_scroll setAnchorPoint:ccp(0,0)];
	[top_scroll setOpacity:220];
	[bottom_scroll setOpacity:220];
	[self addChild:top_scroll z:3];
	[self addChild:bottom_scroll z:3];
	
	ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_CLAMP_TO_EDGE};
	[[top_scroll texture] setTexParameters:&par];
	[[bottom_scroll texture] setTexParameters:&par];
	
	particleholder = [CCSprite node];
	[self addChild:particleholder z:5];
	particles = [NSMutableArray array];
	particles_tba = [NSMutableArray array];
	
	game_objects = [NSMutableArray array];
	duration = BOSS_INFINITE_DURATION;
	
	ui = [CapeGameUILayer cons_g:self];
	[self addChild:ui z:4];
	
	
	self.isTouchEnabled = YES;
	[self schedule:@selector(update:)];
	
	touch_down = NO;
	initial_hold = YES;
	
	current_mode = CapeGameMode_FALLIN;
	gameobjects_tbr = [NSMutableArray array];
	
	count_as_death = NO;
	gameend_constant_speed = 0;
	[ui itembar_set_visible:NO];
	
	credits_logo = [CreditsFlybyObject cons_logo];
	[self add_gameobject:credits_logo];
	credits_text = NULL;
	credits_mode = 0;
	credits_bone_spawn = 40;
	
	return self;
}

-(void)credits_update {
	if ([credits_logo has_enter] && credits_mode == 0) {
		credits_mode = 1;
		
	} else if (credits_mode == 1) {
		[self credits_mode_update_text:@"Credits" to_mode:2];
		
	} else if (credits_mode == 2) {
		[self credits_mode_update_text:@"Programming And Design:\nSPOTCO" to_mode:3];
		
	} else if (credits_mode == 3) {
		[self credits_mode_update_text:@"Art:\nTom Chang" to_mode:4];
		
	} else if (credits_mode == 4) {
		[self credits_mode_update_text:@"Music:\nJoshua Kaplan\n(openheartsound.com)" to_mode:5];
		
	} else if (credits_mode == 5) {
		[self credits_mode_update_text:@"Special Thanks To:\nPhrazy, Chet & Judy\nThomas Kaghan\nEveryone on Testflight!" to_mode:6];
		
	} else if (credits_mode == 6) {
		[self credits_mode_update_text:@"Thanks for playing!" to_mode:7];
		
	} else if (credits_mode == 7) {
		[credits_logo do_exit];
		if ([credits_logo has_exit]) {
			credits_mode = 8;
			[self credits_end];
		}
	}
	
	if (credits_mode < 6 && credits_mode > 1) {
		credits_bone_spawn-=[Common get_dt_Scale];
		if (credits_bone_spawn <= 0) {
			credits_bone_spawn = 40;
			[self add_gameobject:[CapeGameBone cons_pt:[Common screen_pctwid:1.2 pcthei:float_random(0.15, 0.85)]]];
		}
	}
	
}

-(void)credits_mode_update_text:(NSString*)text to_mode:(int)mode {
	if (credits_text == NULL) {
		credits_text = [CreditsFlybyObject cons_text:text];
		[self add_gameobject:credits_text];
		credits_ct = 200;
		[Player character_bark];
	}
	
	if ([credits_text has_enter]) {
		if (credits_ct > 0) {
			credits_ct -= [Common get_dt_Scale];
		} else {
			[credits_text do_exit];
		}
		
		if ([credits_text has_exit]) {
			[self remove_gameobject:credits_text];
			credits_text = NULL;
			credits_mode = mode;
		}
		
	}
}

@end

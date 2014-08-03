#import "Player.h"
#import "PlayerEffectParams.h"
#import "GameEngineLayer.h"
#import "GameItemCommon.h"
#import "UsedItem.h"
#import "MagnetItemEffect.h"
#import "ArmorBreakEffect.h"
#import "JumpPadParticle.h" 
#import "DataStore.h"
#import "Cannon.h"
#import "DogRocketEffect.h"
#import "RotateFadeOutParticle.h"


#define IMGWID 64
#define IMGHEI 58
#define IMG_OFFSET_X -0
#define IMG_OFFSET_Y -0

#define DEFAULT_GRAVITY -0.5

#define HITBOX_RESCALE 0.7

#define TRAIL_MIN 8
#define TRAIL_MAX 15

#define DATASTORE_KEY_CUR_CHARACTER @"cur_character"

@interface NSMutableDictionary (hash_with_anim_mode)
-(id)get:(player_anim_mode)k;
-(void)set:(player_anim_mode)k v:(id)v;
@end

@implementation NSMutableDictionary (hash_with_anim_mode)

-(id)get:(player_anim_mode)k {
    id rtv = [self objectForKey:[NSValue value:&k withObjCType:@encode(player_anim_mode)]];
    if (rtv == NULL) [NSException raise:@"anim hash get was null" format:@"for mode %d",k];
    return rtv;
}

-(void)set:(player_anim_mode)k v:(id)v {
    if (v == NULL) [NSException raise:@"anim hash set was null" format:@"for mode %d",k];
    [self setObject:v forKey:[NSValue value:&k withObjCType:@encode(player_anim_mode)]];
}

@end


@implementation Player {
	int armor_sparkle_ct;
}
@synthesize vx,vy;
@synthesize player_img;
@synthesize current_island;
@synthesize up_vec;
@synthesize start_pt;
@synthesize last_ndir,movedir;
@synthesize floating,dashing,dead;
@synthesize current_swingvine;
@synthesize current_cannon;

/* static set player character */

static NSString* CURRENT_CHARACTER;
static NSDictionary* ID_TO_NAME;
static NSDictionary* ID_TO_FULLNAME;
static NSDictionary* ID_TO_POWERDESC;

+(void)initialize {
	ID_TO_NAME = @{
		TEX_DOG_RUN_1: @"OG",
		TEX_DOG_RUN_2: @"Cate",
		TEX_DOG_RUN_3: @"Penny",
		TEX_DOG_RUN_4: @"Spot",
		TEX_DOG_RUN_5: @"Chubs",
		TEX_DOG_RUN_6: @"Dubs",
		TEX_DOG_RUN_7: @"Brock"
	};
	
	ID_TO_FULLNAME = @{
		TEX_DOG_RUN_1: @"OG the Mutt",
		TEX_DOG_RUN_2: @"Cate the Corgi",
		TEX_DOG_RUN_3: @"Penny the Poodle",
		TEX_DOG_RUN_4: @"Spot the Dalmation",
		TEX_DOG_RUN_5: @"Chubs the Pug",
		TEX_DOG_RUN_6: @"Dubs the Husky",
		TEX_DOG_RUN_7: @"Brock the Lab"
	};
	
	ID_TO_POWERDESC = @{
		TEX_DOG_RUN_1: @"None",
		TEX_DOG_RUN_2: @"double lives",
		TEX_DOG_RUN_3: @"higher jump",
		TEX_DOG_RUN_4: @"triple jump",
		TEX_DOG_RUN_5: @"auto magnet",
		TEX_DOG_RUN_6: @"longer dash",
		TEX_DOG_RUN_7: @"double dash"
	};
    
    CURRENT_CHARACTER = [DataStore get_str_for_key:DATASTORE_KEY_CUR_CHARACTER];
    if (CURRENT_CHARACTER == NULL) CURRENT_CHARACTER = TEX_DOG_RUN_1;
}

+(void)character_bark {
	if (streq(CURRENT_CHARACTER, TEX_DOG_RUN_2) || streq(CURRENT_CHARACTER, TEX_DOG_RUN_3) || streq(CURRENT_CHARACTER, TEX_DOG_RUN_5)) {
		[AudioManager playsfx:SFX_BARK_HIGH];
	} else if (streq(CURRENT_CHARACTER, TEX_DOG_RUN_6) || streq(CURRENT_CHARACTER, TEX_DOG_RUN_7)) {
		[AudioManager playsfx:SFX_BARK_LOW];
	} else {
		[AudioManager playsfx:SFX_BARK_MID];
	}
}

+(BOOL)current_character_has_power:(CharacterPower)power {
	if (power == CharacterPower_DOUBLELIVES) {
		return streq(CURRENT_CHARACTER, TEX_DOG_RUN_2);
		
    } else if (power == CharacterPower_AUTOMAGNET) {
        return streq(CURRENT_CHARACTER, TEX_DOG_RUN_5);
        
    } else if (power == CharacterPower_HIGHERJUMP) {
        return streq(CURRENT_CHARACTER, TEX_DOG_RUN_3);
        
    } else if (power == CharacterPower_SLOWFALL) {
        return streq(CURRENT_CHARACTER, TEX_DOG_RUN_3);
        
    } else if (power == CharacterPower_TRIPLEJUMP) {
        return streq(CURRENT_CHARACTER, TEX_DOG_RUN_4);
        
    } else if (power == CharacterPower_LONGDASH) {
        return streq(CURRENT_CHARACTER, TEX_DOG_RUN_6);
        
    } else if (power == CharacterPower_DOUBLEDASH) {
        return streq(CURRENT_CHARACTER, TEX_DOG_RUN_7);
        
    }
    return NO;
}

+(void)set_character:(NSString*)tar {
    CURRENT_CHARACTER = tar;
    [DataStore set_key:DATASTORE_KEY_CUR_CHARACTER str_value:tar];
}
+(NSString*)get_character {
    return CURRENT_CHARACTER;
}
+(NSString*)get_name:(NSString*)tar {
	return [ID_TO_NAME objectForKey:tar];
}
+(NSString*)get_full_name:(NSString*)tar {
	return ID_TO_FULLNAME[tar];
}
+(NSString*)get_power_desc:(NSString*)tar {
	return [ID_TO_POWERDESC objectForKey:tar];
}

+(Player*)cons_at:(CGPoint)pt {
	Player *new_player = [Player node];
    [new_player reset_params];
	CCSprite *player_img = [CCSprite node];
    new_player.player_img = player_img;
    new_player.last_ndir = 1;
    new_player.movedir = 1;
    new_player.current_island = NULL;
	
	
	player_img.anchorPoint = ccp(0.5,0);
	player_img.position = ccp(IMG_OFFSET_X * CC_CONTENT_SCALE_FACTOR(),IMG_OFFSET_Y * CC_CONTENT_SCALE_FACTOR());
	
    new_player.up_vec = [VecLib cons_x:0 y:1 z:0];
	[new_player addChild:player_img];
	
    [new_player cons_anim];
	
    new_player.start_pt = pt;
    new_player.position = new_player.start_pt;
	
	return new_player;
}

-(id)init {
    self = [super init];
	
    prevndir = 1;
    cur_scy = 1;
    inair_ct = 0;
	
	sweatanim = [CCSprite node];
	[sweatanim runAction:[self make_sweatanim]];
	[sweatanim setPosition:ccp(-30/CC_CONTENT_SCALE_FACTOR(),45/CC_CONTENT_SCALE_FACTOR())];
	[sweatanim setVisible:NO];
	[self addChild:sweatanim z:10];
	
	dashlines = [CCSprite node];
	[dashlines runAction:[self make_dashlines_anim]];
	[dashlines setPosition:ccp(0,30/CC_CONTENT_SCALE_FACTOR())];
	[dashlines setScale:1.4];
	[dashlines setVisible:NO];
	[self addChild:dashlines];
	
    return self;
}

-(id)make_dashlines_anim {
	CCTexture2D *texture = [Resource get_tex:TEX_DASHJUMPPARTICLES_SS];
	NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_DASHJUMPPARTICLES_SS idname:@"dashline_1"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_DASHJUMPPARTICLES_SS idname:@"dashline_2"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_DASHJUMPPARTICLES_SS idname:@"dashline_3"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_DASHJUMPPARTICLES_SS idname:@"dashline_2"]]];
    return [Common make_anim_frames:animFrames speed:0.1];
}

-(id)make_sweatanim{
	CCTexture2D *texture = [Resource get_tex:TEX_SWEATANIM_SS];
	NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_SWEATANIM_SS idname:@"sweat0"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_SWEATANIM_SS idname:@"sweat1"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_SWEATANIM_SS idname:@"sweat2"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_SWEATANIM_SS idname:@"sweat3"]]];
    return [Common make_anim_frames:animFrames speed:0.1];
}

-(BOOL)start_anim:(player_anim_mode)tar {
    if (tar == anim_mode) {
        return NO;
    } else if (current_anim_action != NULL) {
        [player_img stopAction:current_anim_action];
    }
    anim_mode = tar;
    if (armored_ct) {
        current_anim_action = [armored_anims get:anim_mode];
    } else {
        current_anim_action = [normal_anims get:anim_mode];
    }
    [player_img runAction:current_anim_action];
    return YES;
}

-(void)update:(GameEngineLayer*)g {
    game_engine_layer = g;
    
    [self update_ieffects:g];
    
    if (current_island == NULL && current_swingvine == NULL && [[self get_current_params] class] != [DogRocketEffect class]) {
        [self mov_center_rotation];
        
    } else if (current_island != NULL) {
        [self add_running_dust_particles:g];
    }
    
	if ([self get_current_params].cur_airjump_count == 0 && [self get_current_params].cur_dash_count == 0 && current_island == NULL) {
		[sweatanim setVisible:YES];
    } else {
		[sweatanim setVisible:NO];
	}
    
    player_anim_mode cur_param_anim_mode = [[self get_current_params] get_anim];
    if (current_cannon != NULL) {
		cur_param_anim_mode = player_anim_mode_HEAD;
		player_img.position = ccp(-4/CC_CONTENT_SCALE_FACTOR(),-25 / CC_CONTENT_SCALE_FACTOR());
		[self.player_img setVisible:[current_cannon cannon_show_head:self]];
		
	} else {
		//[self.player_img setPosition:ccp(IMG_OFFSET_X,IMG_OFFSET_Y)];
		player_img.position = ccp(IMG_OFFSET_X * CC_CONTENT_SCALE_FACTOR(),IMG_OFFSET_Y * CC_CONTENT_SCALE_FACTOR());
		[self.player_img setVisible:YES];
	}
	
    dashing = (cur_param_anim_mode == player_anim_mode_DASH) || ([[self get_current_params] is_also_dashing]);
	[dashlines setVisible:dashing];
	if ([[self get_current_params] class] == [DashEffect class]) {
		float pct = [self get_current_params].time_left / ((float)[DashEffect dash_effect_length]);
		[dashlines setOpacity:200*pct + 55];
	}
    
    if (current_swingvine != NULL) {
        [self swingvine_attach_anim];
		[self start_anim:player_anim_mode_SWING];
        
    } else if (cur_param_anim_mode == player_anim_mode_RUN_SLOW || cur_param_anim_mode == player_anim_mode_RUN_MED || cur_param_anim_mode == player_anim_mode_RUN_FAST) {
        [self runanim_update];
        
    } else if (cur_param_anim_mode == player_anim_mode_DASH) {
        if (current_island != NULL) {
            cur_scy = last_ndir;
        } else {
            cur_scy = 1;
            self.last_ndir = 1;
        }
		[self start_anim:player_anim_mode_DASH];
        
    } else if (cur_param_anim_mode == player_anim_mode_CAPE) {
        [self start_anim:player_anim_mode_CAPE];
        
    } else if (cur_param_anim_mode == player_anim_mode_ROCKET) {
        if (current_island != NULL) {
            cur_scy = last_ndir;
        } else {
            cur_scy = 1;
            self.last_ndir = 1;
        }
        [self start_anim:player_anim_mode_ROCKET];
        [g add_particle:[RocketParticle cons_x:[self position].x-40 y:[self position].y+20]];
        
    } else if (cur_param_anim_mode == player_anim_mode_HIT) {
		if (current_island != NULL && current_island.ndir < 0) {
			cur_scy = -1;
		} else {
			cur_scy = 1;
		}
        [self start_anim:player_anim_mode_HIT];
        
    } else if (cur_param_anim_mode == player_anim_mode_FLASH) {
        [self start_anim:player_anim_mode_FLASH];
        
    } else if (cur_param_anim_mode == player_anim_mode_SPLASH) {
        cur_scy = 1;
        [self start_anim:player_anim_mode_SPLASH];
        
    } else if (cur_param_anim_mode == player_anim_mode_HEAD) {
		[self start_anim:player_anim_mode_HEAD];
	}
	
	if (self.current_swingvine != NULL) {
		cur_scy = 1;
	}
	
    [self csf_setScaleY:cur_scy];
    [self update_params:g];
    refresh_hitrect = YES;
}

//internal effects system (for effects that should persist)
-(void)update_ieffects:(GameEngineLayer*)g {
    if (new_spd_ct)new_spd_ct--;
    if (new_magnetrad_ct) {
        new_magnetrad_ct--;
        if (new_magnetrad_ct) {
            [GEventDispatcher push_event:[[[GEvent cons_type:GEventType_ITEM_DURATION_PCT] add_f1:((float)new_magnetrad_ct)/[GameItemCommon get_uselength_for:Item_Magnet g:game_engine_layer] f2:0] add_i1:Item_Magnet i2:0]];
        } else {
            [self reset_magnet_ieffect];
			[AudioManager playsfx:SFX_POWERDOWN];
        }
    }
    if (heart_ct) {
        heart_ct--;
        if (heart_ct) {
            [GEventDispatcher push_event:[[[GEvent cons_type:GEventType_ITEM_DURATION_PCT] add_f1:((float)heart_ct)/[GameItemCommon get_uselength_for:Item_Heart g:game_engine_layer] f2:0] add_i1:Item_Heart i2:0]];
        } else {
            [self reset_heart];
        }
    }
    if (armored_ct) {
		[AudioManager play_invincible_for:2];
		
		armor_sparkle_ct+=[Common get_dt_Scale];
		if (armor_sparkle_ct >= 2) {
				[g add_particle:(Particle*)[[[[RotateFadeOutParticle
											   cons_tex:[Resource get_tex:TEX_PARTICLES]
											   rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"star"]]
											  set_vr:float_random(-15, 15)]
											 set_ctmax:30]
											pos:ccp(self.position.x + float_random(-60, 60),self.position.y + float_random(-60, 60))]];
			
			armor_sparkle_ct = 0;
		}
		
        armored_ct--;
        [GEventDispatcher push_event:[[[GEvent cons_type:GEventType_ITEM_DURATION_PCT] add_f1:((float)armored_ct)/[GameItemCommon get_uselength_for:Item_Shield g:game_engine_layer] f2:0] add_i1:Item_Shield i2:0]];
        if (armored_ct == 0) {
            [ArmorBreakEffect cons_at:[self get_center] in:game_engine_layer];
            [self reset_is_armored];
			[AudioManager playsfx:SFX_POWERDOWN];
        }
    }
	if (clock_ct > 0 && [GameControlImplementation get_clockbutton_hold]) {
		clock_ct--;
		[GEventDispatcher push_event:[[[GEvent cons_type:GEventType_ITEM_DURATION_PCT] add_f1:((float)clock_ct)/[GameItemCommon get_uselength_for:Item_Clock g:game_engine_layer] f2:0] add_i1:Item_Clock i2:0]];
		if (clock_ct == 0) {
			[self reset_clockeffect];
			[AudioManager playsfx:SFX_POWERDOWN];
		}
	}
}

#define DEFAULT_SPEED 7
-(int)get_speed {
    return new_spd_ct > 0 ? new_spd : DEFAULT_SPEED;
}

-(void)set_new_spd:(int)spd ct:(int)ct {
    new_spd = spd;
    new_spd_ct = ct;
}

-(void)reset_speed_ieffect {
    new_spd_ct = 0;
}

#define DEFAULT_DASH_MAGNET_RAD 150
-(void)set_magnet_rad:(int)rad ct:(int)ct {
    new_magnetrad = rad;
    new_magnetrad_ct = ct;
    [game_engine_layer add_gameobject:[MagnetItemEffect cons]];
}

-(int)get_magnet_rad {
    if (new_magnetrad_ct > 0) {
        return new_magnetrad;
    } else if (dashing || [Player current_character_has_power:CharacterPower_AUTOMAGNET]) {
        return DEFAULT_DASH_MAGNET_RAD;
    } else {
        return 20;
    }
}

-(void)reset_magnet_ieffect {
    new_magnetrad_ct = 0;
    [GEventDispatcher immediate_event:[[[GEvent cons_type:GEventType_ITEM_DURATION_PCT] add_f1:0 f2:0] add_i1:Item_Magnet i2:0]];
}

-(void)set_armored:(int)time {
    armored_ct = time;
    player_anim_mode tmp_cur_anim_mode = anim_mode;
    anim_mode = -1;
    [self start_anim:tmp_cur_anim_mode];
}

-(BOOL)is_armored {
    return armored_ct > 0;
}

-(void)end_armored {
	armored_ct = 1;
}

-(void)reset_is_armored {
    armored_ct = 0;
    player_anim_mode tmp_cur_anim_mode = anim_mode;
    anim_mode = -1;
    [self start_anim:tmp_cur_anim_mode];
}

-(void)set_heart:(int)time {
    [self reset_heart];
    heart_ct = time;
    [game_engine_layer add_gameobject:[HeartItemEffect cons]];
}

-(BOOL)has_heart {
    return heart_ct > 0;
}

-(void)reset_heart {
    heart_ct = 0;
    [GEventDispatcher immediate_event:[[[GEvent cons_type:GEventType_ITEM_DURATION_PCT] add_f1:0 f2:0] add_i1:Item_Heart i2:0]];
}

-(void)set_clockeffect:(int)time {
	clock_ct = time;
	[game_engine_layer add_gameobject:[ClockItemEffect cons]];
}

-(BOOL)is_clockeffect {
	return clock_ct > 0;
}

-(void)reset_clockeffect {
	clock_ct = 0;
	[GEventDispatcher immediate_event:[[[GEvent cons_type:GEventType_ITEM_DURATION_PCT] add_f1:0 f2:0] add_i1:Item_Clock i2:0]];
}

-(void)reset_all_ieffects {
    [self reset_magnet_ieffect];
    [self reset_speed_ieffect];
    [self reset_is_armored];
    [self reset_heart];
	[self reset_clockeffect];
}

-(void)mov_center_rotation {
    Vec3D dv = [VecLib cons_x:vx y:vy z:0];
    dv = [VecLib normalize:dv];
    
    float rot = -[Common rad_to_deg:[VecLib get_angle_in_rad:dv]];
    float sig = [Common sig:rot];
    rot = sig*sqrtf(ABS(rot));
    [self setRotation:rot];
    
}

-(CGPoint)get_center {
    HitRect phit = [self get_hit_rect_ignore_noclip];
    return ccp((phit.x2-phit.x1)/2+phit.x1,(phit.y2-phit.y1)/2+phit.y1);
}

-(void)add_running_dust_particles:(GameEngineLayer*)g {
    float vel = sqrtf(powf(vx,2)+powf(vy,2));
    if (vel > TRAIL_MIN) {
        float ch = (vel-TRAIL_MIN)/(TRAIL_MAX - TRAIL_MIN)*100;
        if (arc4random_uniform(100) < ch) {
            Vec3D dv = [current_island get_tangent_vec];
            dv=[VecLib normalize:dv];
            dv=[VecLib scale:dv by:-2.5];
            dv.x += float_random(-3, 3);
            dv.y += float_random(-3, 3);
            [g add_particle:[StreamParticle cons_x:[self position].x y:[self position].y vx:dv.x vy:dv.y]];
        }
    }
}

-(void)swingvine_attach_anim {
    //smoothing anim for swingvine attach, see swingvine update (does not force rotation until curanim is _SWING_ANIM
    if (![Common fuzzyeq_a:[self rotation] b:-90 delta:1]) {
        float dir = [Common shortest_dist_from_cur:[self rotation] to:-90]*0.8;
        self.rotation += dir;
    } else {
        [self start_anim:player_anim_mode_SWING];
    }
}

static int lastswap = 0;

-(void)runanim_update {
    if (self.last_ndir != prevndir && self.last_ndir < 0) { //if land on reverse, start flip
        flipctr = 10;
    } else if (flipctr <= 0 && self.current_island == NULL && cur_scy < 0) {//if jump from reverse, startflip
        flipctr = 10;
    }
    prevndir = self.last_ndir;
    
    lastswap--;
    
    if (flipctr > 0) {
        cur_scy = last_ndir;
        flipctr--;
        [self start_anim:player_anim_mode_FLIP];
        
        if (flipctr == 0 && self.current_island == NULL && cur_scy < 0) { //finish jump from reverse flip
            cur_scy = 1;
        }
        
    } else if (current_island == NULL) {
        cur_scy = 1;
        if (floating) {
            [self start_anim:player_anim_mode_RUN_FAST];
        } else {
            [self start_anim:player_anim_mode_RUN_NONE];
        }
        
    } else {
        last_ndir = current_island.ndir;
        cur_scy = last_ndir;
        
        if (lastswap > 0) return;
        
        float vel = sqrtf(powf(vx,2)+powf(vy,2));
        if (vel > 10) {
            if([self start_anim:player_anim_mode_RUN_FAST]) lastswap = 10;
        } else if (vel > 5) {
            if([self start_anim:player_anim_mode_RUN_MED]) lastswap = 10;
        } else {
            if([self start_anim:player_anim_mode_RUN_SLOW]) lastswap = 10;
        }
    }
}

-(void)update_params:(GameEngineLayer*)g {
    if (temp_params != NULL) {
        [temp_params update:self g:g];
        [temp_params decrement_timer];
        if (temp_params.time_left == 0) {
            [temp_params effect_end];
            temp_params = NULL;
        }
    } else {
		[current_params update:self g:g];
	}
}

/* playerparam system */

-(PlayerEffectParams*) get_current_params {
    if (temp_params != NULL) {
        return temp_params;
    } else {
        return current_params;
    }
}
-(PlayerEffectParams*) get_default_params {
    return current_params;
}
-(void) reset {
	[self setPosition:start_pt];
    //position_ = start_pt;
    current_island = NULL;
    up_vec = [VecLib cons_x:0 y:1 z:0];
    vx = 0;
    vy = 0;
    //rotation_ = 0;
    [self setRotation:0];
	last_ndir = 1;
    floating = NO;
    dashing = NO;
    dead = NO;
    current_swingvine = NULL;
	current_cannon = NULL;
    [self start_anim:player_anim_mode_RUN_NONE];
    [self reset_all_ieffects];
    [self reset_params];
}
-(void) reset_params {
    if (temp_params != NULL) {
        [temp_params effect_end];
        temp_params = NULL;
    }
    if (current_params != NULL) {
        [current_params effect_end];
        current_params = NULL;
    }
    current_params = [[PlayerEffectParams alloc] init];
	current_params.player = self;
    current_params.cur_gravity = DEFAULT_GRAVITY;
    current_params.cur_airjump_count = 1;
    current_params.cur_dash_count = 1;
    current_params.time_left = -1;
}
-(void)add_effect:(PlayerEffectParams*)effect {
    if (temp_params != NULL) {
        if (game_engine_layer != NULL) {
            [temp_params effect_end];
        }
        temp_params = NULL;
    }
    temp_params = effect;
    [temp_params effect_begin:self];
}

-(void)add_effect_suppress_current_end_effect:(PlayerEffectParams *)effect {
    if (temp_params != NULL) {
        temp_params = NULL;
    }
    temp_params = effect;
    [temp_params effect_begin:self];
}

-(void)remove_temp_params:(GameEngineLayer*)g {
    if (temp_params != NULL) {
        [temp_params effect_end];
        temp_params = NULL;
    }
}

-(HitRect) get_hit_rect_ignore_noclip {
    PlayerEffectParams *cur = [self get_current_params];
    int cur_nc = cur.noclip;
    cur.noclip = 0;
    HitRect gets = [self get_hit_rect];
    cur.noclip = cur_nc;
    return gets;
}

-(HitRect)get_jump_rect {
    return [Common hitrect_cons_x1:[self position].x-25 y1:[self position].y wid:50 hei:4];
}

BOOL refresh_hitrect = YES;
HitRect cached_rect;
-(HitRect) get_hit_rect {
    if ([self get_current_params].noclip) {
        return [Common hitrect_cons_x1:0 y1:0 wid:0 hei:0];
    } else if (refresh_hitrect == NO) {
        return cached_rect;
    }
    
    Vec3D v = [VecLib cons_x:up_vec.x y:up_vec.y z:0];
    Vec3D h = [VecLib cross:v with:[VecLib Z_VEC]];
    float x = self.position.x;
    float y = self.position.y;
    h=[VecLib normalize:h];
    v=[VecLib normalize:v];
    h=[VecLib scale:h by:IMGWID/2 * HITBOX_RESCALE];
    v=[VecLib scale:v by:IMGHEI * HITBOX_RESCALE];

    CGPoint pts[4];
    pts[0] = ccp(x-h.x , y-h.y);
    pts[1] = ccp(x+h.x , y+h.y);
    pts[2] = ccp(x-h.x+v.x , y-h.y+v.y);
    pts[3] = ccp(x+h.x+v.x , y+h.y+v.y);
    
    float x1 = pts[0].x;
    float y1 = pts[0].y;
    float x2 = pts[0].x;
    float y2 = pts[0].y;

    for (int i = 0; i < 4; i++) {
        x1 = MIN(pts[i].x,x1);
        y1 = MIN(pts[i].y,y1);
        x2 = MAX(pts[i].x,x2);
        y2 = MAX(pts[i].y,y2);
    }
    
    refresh_hitrect = NO;
    cached_rect = [Common hitrect_cons_x1:x1 y1:y1 x2:x2 y2:y2];
    return cached_rect;
}

/* animation cfgs */

-(NSArray*)get_run_animstr {
    NSMutableArray *run = [NSMutableArray array];
    for(int i = 0; i < 5; i++) {
        [run addObject:@"run_0"];[run addObject:@"run_1"];[run addObject:@"run_2"];[run addObject:@"run_3"];
    }
    [run addObject:@"run_blink"];[run addObject:@"run_1"];[run addObject:@"run_2"];[run addObject:@"run_3"];
    return run;
}

-(void)do_run_anim {
    [self start_anim:player_anim_mode_RUN_FAST];
}

-(void)do_stand_anim {
    [self start_anim:player_anim_mode_RUN_NONE];
}

-(void)do_cape_anim {
	[self start_anim:player_anim_mode_CAPE];
	[dashlines setVisible:NO];
	[sweatanim setVisible:NO];
}

-(void)cons_anim {
    normal_anims = [NSMutableDictionary dictionary];
    armored_anims = [NSMutableDictionary dictionary];
    [self load_anims_into:normal_anims from_ss:[Player get_character]];
    [self load_anims_into:armored_anims from_ss:TEX_DOG_ARMORED]; //TODO -- the actual thing
    [self start_anim:player_anim_mode_RUN_NONE];
}

-(void)load_anims_into:(NSMutableDictionary*)d from_ss:(NSString*)tar {
	NSArray *run = [self get_run_animstr];
    [d set:player_anim_mode_RUN_SLOW v:[self cons_anim_repeat_texstr:tar speed:0.075 frames:run]];
    [d set:player_anim_mode_RUN_MED v:[self cons_anim_repeat_texstr:tar speed:0.06 frames:run]];
    [d set:player_anim_mode_RUN_FAST v:[self cons_anim_repeat_texstr:tar speed:0.05 frames:run]];
    [d set:player_anim_mode_RUN_NONE v:[self cons_anim_repeat_texstr:tar speed:0.075 frames:[NSArray arrayWithObjects:@"run_0",nil]]];
    [d set:player_anim_mode_ROCKET v:[self cons_anim_repeat_texstr:tar speed:0.1 frames:[NSArray arrayWithObjects:@"rocket_0",@"rocket_1",@"rocket_2",nil]]];
    [d set:player_anim_mode_CAPE v:[self cons_anim_repeat_texstr:tar speed:0.1 frames:[NSArray arrayWithObjects:@"cape_0",@"cape_1",@"cape_2",@"cape_3",nil]]];
    [d set:player_anim_mode_HIT v:[self cons_anim_once_texstr:tar speed:0.1 frames:[NSArray arrayWithObjects:@"hit_1",@"hit_2",@"hit_3",nil]]];
    [d set:player_anim_mode_SPLASH v:[self cons_anim_once_texstr:TEX_DOG_SPLASH speed:0.1 frames:[NSArray arrayWithObjects:@"splash1",@"splash2",@"splash3",@"",nil]]];
    [d set:player_anim_mode_DASH v:[self cons_anim_repeat_texstr:tar speed:0.05 frames:[NSArray arrayWithObjects:@"roll_0",@"roll_1",@"roll_2",@"roll_3",nil]]];
    [d set:player_anim_mode_SWING v:[self cons_anim_repeat_texstr:tar speed:1 frames:[NSArray arrayWithObjects:@"swing_0",nil]]];
    [d set:player_anim_mode_FLASH v:[self cons_anim_repeat_texstr:tar speed:0.1 frames:[NSArray arrayWithObjects:@"hit_0",@"hit_0_flash",nil]]];
    [d set:player_anim_mode_FLIP v:[self cons_anim_once_texstr:tar speed:0.025 frames:[NSArray arrayWithObjects:@"flip_4",@"flip_3",@"flip_2",@"flip_1",@"flip_0",nil]]];
	[d set:player_anim_mode_HEAD v:[self cons_anim_repeat_texstr:tar speed:0.075 frames:[NSArray arrayWithObjects:@"head",nil]]];
}

-(player_anim_mode)cur_anim_mode {
    return anim_mode;
}

-(id)cons_anim_repeat_texstr:(NSString*)texkey speed:(float)speed frames:(NSArray*)a {
    NSArray *animFrames = [self cons_texstr:texkey framestrs:a];
    return [Common make_anim_frames:animFrames speed:speed];
}
-(id)cons_anim_once_texstr:(NSString*)texkey speed:(float)speed frames:(NSArray*)a {
    NSArray *animFrames = [self cons_texstr:texkey framestrs:a];
    id anim = [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:speed] restoreOriginalFrame:NO];
    return anim;
}
-(NSArray*)cons_texstr:(NSString*)tar framestrs:(NSArray*)a {
    NSMutableArray* animFrames = [NSMutableArray array];
    for (NSString* key in a) {
		CCTexture2D *tex = [Resource get_tex:tar];
        [animFrames addObject:[CCSpriteFrame frameWithTexture:tex
                                                         rect:[FileCache get_cgrect_from_plist:tar idname:key]]];
    }
    return animFrames;
}

-(void)setColor:(ccColor3B)color {
    [super setColor:color];
	for(CCSprite *sprite in [self children]) {
        [sprite setColor:color];
	}
}
- (void)setOpacity:(GLubyte)opacity {
	[super setOpacity:opacity];
	for(CCSprite *sprite in [self children]) {
		sprite.opacity = opacity;
	}
}

-(void)dealloc {
	[player_img stopAllActions];
	[self stopAllActions];
	[normal_anims removeAllObjects];
	[armored_anims removeAllObjects];
	[sweatanim stopAllActions];
	[dashlines stopAllActions];
	game_engine_layer = NULL;
    [self removeAllChildrenWithCleanup:YES];
}

@end

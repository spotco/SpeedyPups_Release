#import "CopterRobot.h"
#import "GameEngineLayer.h"
#import "JumpPadParticle.h"
#import "EnemyBomb.h"
#import "HitEffect.h"
#import "DazedParticle.h"
#import "LauncherRobot.h"
#import "BrokenMachineParticle.h"
#import "GameMain.h"
#import "ScoreManager.h"

#import "NRobotBossComponents.h"

#define ARM_DEFAULT_POSITION ccp(-38,-47)

@implementation CopterRobot

static const float PLAYER_FOLLOW_OFFSET = 50;
static const float SLOWSPEED = 5;
static const float FLYOFFSPEED = 12;

static const float VIBRATION_SPEED = 0.1;
static const float VIBRATION_AMPLITUDE = 10;

static const int DASHWAITDIST = 400;
static const int DASHSPEED = 7;
static const int DASHWAITCT = 100;

static const int SKYFIRE_SPEED = 60;

static const int RAPIDFIRE_RELOAD_SPEED = 85;
static const int RAPIDFIRE_CT = 560;
static const int RAPIDFIRE_ROCKETSPEED = 5;

static const int TRACKINGFIRE_CT = 500;
static const int TRACKINGFIRE_DIST = 500;
static const int TRACKINGFIRE_RELOAD = 60;
static const int TRACKINGFIRE_ROCKETSPEED = 8;

static const float RECOIL_DIST = 25;
static const float RECOIL_CT = 10;

static int DEFAULT_HP;


#define DEFAULT_SCALE 1.2

#define BODY @"body"
#define BODY_BROKEN @"body_broken"
#define ARM @"arm"
#define ARM_BROKEN @"arm_broken"

+(CopterRobot*)cons_with_g:(GameEngineLayer *)g {
    return [[CopterRobot node] cons_with_g:g];
}

#define RPOS_CAT_TAUNT_POS ccp(300,250)
#define RPOS_CAT_DEFAULT_POS ccp(1500,500)
#define CAT_TAUNT_OFFSET ccp(-1000,0)
#define CENTER_POS ccp(player.position.x,groundlevel)
#define LERP_TO(pos1,pos2,div) ccp(pos1.x+(pos2.x-pos1.x)/div,pos1.y+(pos2.y-pos1.y)/div)

-(CopterRobot*)cons_with_g:(GameEngineLayer*)g {
    [self cons_anims];
	[self setScale:1];
	
	if ([GameMain GET_BOSS_1_HEALTH]) {
		DEFAULT_HP = 1;
	} else {
		DEFAULT_HP = 5;
	}
	hp = DEFAULT_HP;
	
    active = YES;
    player_pos = g.player.position;
	
    //cur_mode = CopterMode_IntroAnim;
    cur_mode = CopterMode_CatIn;
	
	//rel_pos = ccp(800,0);
	rel_pos = CAT_TAUNT_OFFSET;
	[self apply_rel_pos];
	[self set_bounds_and_ground:g];
    actual_pos.y = groundlevel+360;
    [self setPosition:actual_pos];
	
	cat_body = [NCatBossBody cons];
	[self addChild:cat_body];
	cat_body_rel_pos = ccp(2000,800);
	[cat_body csf_setScale:0.85];
	[cat_body setVisible:YES];
    
    return self;
}

-(BOOL)can_hit {
    return (cur_mode != CopterMode_GotHit_FlyOff) && (cur_mode != Coptermode_DeathExplode) && (cur_mode != CopterMode_ToRemove);
}

-(void)update_cat_body_flyin_to:(CGPoint)tar transition_to:(CopterMode)mode {
	[cat_body stand_anim];
	cat_body_rel_pos = LERP_TO(cat_body_rel_pos, tar, 15.0);
	
	if (CGPointDist(cat_body_rel_pos, tar) < 10) {
		cur_mode = mode;
		[cat_body laugh_anim];
		delay_ct = 80;
	}
}

-(void)update_taunt_transition_to:(CopterMode)mode {
	delay_ct-=[Common get_dt_Scale];
	if (delay_ct <= 0) {
		cur_mode = mode;
		[cat_body stand_anim];
	}
}

-(void)update_robot_body_in_robotpos:(CGPoint)robot_pos catpos:(CGPoint)cat_pos transition_to:(CopterMode)mode {
	cat_body_rel_pos = LERP_TO(cat_body_rel_pos, cat_pos, 15.0);
	if (CGPointDist(cat_body_rel_pos, cat_pos) < 100) {
		cur_mode = mode;
		delay_ct = 20;
	}
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    player_pos = player.position;
    if (cur_mode != CopterMode_ToRemove) {
        [self set_bounds_and_ground:g];
        [GEventDispatcher push_event:[[GEvent cons_type:GEventType_BOSS1_TICK] add_i1:hp i2:DEFAULT_HP]];
    }
    
    if (hp <= DEFAULT_HP/2 && !setbroke) {
        setbroke = YES;
        [body setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:BODY_BROKEN]];
        [arm setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:ARM_BROKEN]];
    }
    
    [self anim_arm];
    [self anim_vibration];
    [self anim_recoil];
    
    if ([self can_hit] && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]  && !player.dead) {
        rel_pos = ccp(actual_pos.x - player.position.x,actual_pos.y-player.position.y);
        if (player.dashing || [player is_armored]) {
            hp--;
            if (hp <= 0) {
                cur_mode = Coptermode_DeathExplode;
                rel_pos = ccp(actual_pos.x-g.player.position.x,actual_pos.y-g.player.position.y);
                ct = 130;
                
            } else {
                cur_mode = CopterMode_GotHit_FlyOff;
                float velx = float_random(0, FLYOFFSPEED);
                float vely = (FLYOFFSPEED-velx)*(int_random(0, 2)?1:-1);
                flyoffdir = ccp(SIG(actual_pos.x-player.position.x)*velx,vely);
                [AudioManager playsfx:SFX_ROCKBREAK];
                [AudioManager playsfx:SFX_ROCKET_SPIN];
                
            }
			[g shake_for:10 intensity:4];
			[g freeze_frame:6];
            
        } else if (!player.dead) {
            cur_mode = CopterMode_Killed_Player;
            [player add_effect:[HitEffect cons_from:[player get_default_params] time:40]];
            [DazedParticle cons_effect:g tar:player time:40];
            [AudioManager playsfx:SFX_HIT];
            [g.get_stats increment:GEStat_ROBOT];
			[g shake_for:15 intensity:6];
			[g freeze_frame:6];
            
        }
    }
    
    if (cur_mode == CopterMode_ToRemove) {
        [g remove_gameobject:self];
        return;
		
	} else if (cur_mode == CopterMode_CatIn) {
		[g set_target_camera:[Common cons_normalcoord_camera_zoom_x:94 y:38 z:131]];
		[cat_body csf_setScaleX:-1];
		[self update_cat_body_flyin_to:RPOS_CAT_TAUNT_POS transition_to:CopterMode_CatTaunt];
		if (cur_mode != CopterMode_CatIn) {
			[AudioManager playsfx:SFX_CAT_LAUGH];
		}
		[cat_body setPosition:CGPointAdd(ccp(-CAT_TAUNT_OFFSET.x,-CAT_TAUNT_OFFSET.y), cat_body_rel_pos)];
		
	} else if (cur_mode == CopterMode_CatTaunt) {
		[self update_taunt_transition_to:CopterMode_CatOut];
		[cat_body setPosition:CGPointAdd(ccp(-CAT_TAUNT_OFFSET.x,-CAT_TAUNT_OFFSET.y), cat_body_rel_pos)];
		
	} else if (cur_mode == CopterMode_CatOut) {
		[self update_robot_body_in_robotpos:ccp(1500,0) catpos:RPOS_CAT_DEFAULT_POS transition_to:CopterMode_IntroAnim];
		if (cur_mode != CopterMode_CatOut) {
			rel_pos = ccp(900,0);
			[AudioManager playsfx:SFX_BOSS_ENTER];
			[cat_body setVisible:NO];
		}
		[cat_body setPosition:CGPointAdd(ccp(-CAT_TAUNT_OFFSET.x,-CAT_TAUNT_OFFSET.y), cat_body_rel_pos)];
		
    } else if (cur_mode == CopterMode_IntroAnim) {
        [self intro_anim:g];
        
    } else if (cur_mode == CopterMode_LeftDash) {
        [self left_dash:g];
        
    } else if (cur_mode == CopterMode_RightDash) {
        [self right_dash:g];
        
    } else if (cur_mode == CopterMode_GotHit_FlyOff) {
        [self got_hit_flyoff:g];
        
    } else if (cur_mode == CopterMode_Killed_Player) {
        [self killed_player:g];
        
    } else if (cur_mode == CopterMode_SkyFireLeft) {
        [self skyfire_left:g];
        
    } else if (cur_mode == CopterMode_RapidFireRight) {
        [self rapidfire_right:g];
        
    } else if (cur_mode == CopterMode_TrackingFireLeft) {
        [self trackingfire_left:g];
        
    } else if (cur_mode == Coptermode_DeathExplode) {
        [self death_explode:g];
        
    } else if (cur_mode == Coptermode_BombWaveRight) {
        [self bombwave_right:g];
        
    } else if (cur_mode == Coptermode_BombDropRight) {
        [self bombdrop_right:g];
        
    } else if (cur_mode == Coptermode_BombDropLeft) {
        [self bombdrop_left:g];
        
    }
    
	if (cur_mode == CopterMode_CatIn || cur_mode == CopterMode_CatOut || cur_mode == CopterMode_CatTaunt) {
		[self setPosition:ccp(player.position.x+CAT_TAUNT_OFFSET.x,groundlevel)];
	} else {
		[self setPosition:ccp(actual_pos.x+vibration.x+recoil.x,actual_pos.y+vibration.y+recoil.y)];
	}
    

	sfx_ct -= [Common get_dt_Scale];
	if (sfx_ct <= 0) {
		if (CGPointDist(player.position, [self position]) < 250) {
			[AudioManager playsfx:SFX_COPTER_FLYBY];
			sfx_ct = 150;
		}
	}
}


-(void)get_random_action:(Side)s {
	[AudioManager playsfx:SFX_BOSS_ENTER];
    if (s == Side_Left) {
        lct = (lct+1)%4;
        if (lct == 1) {
            cur_mode = CopterMode_RightDash;
            rel_pos = ccp(-600,30);
            ct = DASHWAITCT;
            [self apply_rel_pos];
            
        } else if (lct == 2) {
            cur_mode = CopterMode_RapidFireRight;
            rel_pos = ccp(-600,0);
            actual_pos = ccp(rel_pos.x+player_pos.x,groundlevel + 75);
            ct = RAPIDFIRE_CT;
            
        } else if (lct == 0) {
            cur_mode = Coptermode_BombWaveRight;
            actual_pos = ccp(player_pos.x-550,groundlevel + 300);
            rel_pos = ccp(actual_pos.x-player_pos.x,actual_pos.y-player_pos.y);
            ct = 500;
            vr = 1;
            
        } else if (lct == 3){
            cur_mode = Coptermode_BombDropRight;
            actual_pos = ccp(player_pos.x-750,groundlevel + 400);
            rel_pos = ccp(actual_pos.x-player_pos.x,actual_pos.y-player_pos.y);
            
        } else { NSLog(@"ERRORinG_rand_act"); }
        
    } else {
        rct = (rct+1)%4;
        if (rct == 0) {
            cur_mode = CopterMode_LeftDash;
            rel_pos = ccp(800,30);
            ct = DASHWAITCT;
            [self apply_rel_pos];
            
        } else if (rct == 1) {
            cur_mode = CopterMode_SkyFireLeft;
            rel_pos = ccp(1500,420);
            actual_pos = ccp(rel_pos.x+player_pos.x,groundlevel+rel_pos.y);
            
        } else if (rct == 2) {
            cur_mode = CopterMode_TrackingFireLeft;
            rel_pos = ccp(800,30);
            [self apply_rel_pos];
            ct = TRACKINGFIRE_CT;
            
        } else if (rct == 3) {
            cur_mode = Coptermode_BombDropLeft;
            actual_pos = ccp(player_pos.x+750,groundlevel + 400);
            rel_pos = ccp(actual_pos.x-player_pos.x,actual_pos.y-player_pos.y);
            
        } else { NSLog(@"ERRORinG_rand_act"); }
    }
}

-(void)bombdrop_left:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:90 y:60 z:131]];
    [self setScaleX:-1];
    ct++;
    if (rel_pos.x > -300) {
        rel_pos.x -= 2.5 * [Common get_dt_Scale];
        actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
        if (ct%40==0) {
            CGPoint noz = [self get_nozzle];
            [g add_gameobject:[EnemyBomb cons_pt:noz v:ccp(float_random(1,5),float_random(-4,4))]];
			[AudioManager playsfx:SFX_ROCKET_LAUNCH];
            [self apply_recoil];
            [LauncherRobot explosion:g at:noz];
        }
        
        
    } else {
        [self get_random_action:Side_Left];
    }
}

-(void)bombdrop_right:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:280 y:60 z:131]];
    [self setScaleX:1];
    ct++;
    if (rel_pos.x < 500) {
        rel_pos.x += 2.5 * [Common get_dt_Scale];
        actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
        if (ct%40==0) {
            CGPoint noz = [self get_nozzle];
            [g add_gameobject:[EnemyBomb cons_pt:noz v:ccp(float_random(5,7),float_random(0,4))]];
			[AudioManager playsfx:SFX_ROCKET_LAUNCH];
            [self apply_recoil];
            [LauncherRobot explosion:g at:noz];
        }
        
        
    } else {
        [self get_random_action:Side_Right];
    }
}

-(void)bombwave_right:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:320 y:80 z:131]];
    [self setScaleX:1];
    
    if (rel_pos.x < -400) {
        rel_pos.x += 5 * [Common get_dt_Scale];
        [self setRotation:-45];
    } else if (ct > 0) {
        ct--;
        ct2++;
        if (ct%50==0) {
            vr *= -1;
            
        }
        int firespeed = 40+50*(ct/500.0);
        [self setRotation:[self rotation]+vr];
        if (ct2 > firespeed) {
            CGPoint noz = [self get_nozzle];
            [g add_gameobject:[EnemyBomb cons_pt:noz v:ccp(float_random(7,18),float_random(2,9))]];
			[AudioManager playsfx:SFX_ROCKET_LAUNCH];
            [self apply_recoil];
            [LauncherRobot explosion:g at:noz];
            ct2 = 0;
        }
        
    } else {
        [self setRotation:[self rotation]*0.9];
        rel_pos.x+=DASHSPEED * [Common get_dt_Scale];
        if (rel_pos.x > 500) {
            [self get_random_action:Side_Right];
        }
    }
    
    actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
}

-(void)death_explode:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:140 y:80 z:131]];
    [self setOpacity:160];
    [self setRotation:[self rotation]+20];
    
    actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
    
    if (ct%15==0&&ct>20) {
        [g add_particle:[RelativePositionExplosionParticle cons_x:[self position].x+float_random(-60, 60)
                                                                y:[self position].y+float_random(-60, 60)
                                                           player:g.player.position]];
        [AudioManager playsfx:SFX_EXPLOSION];
		[g shake_for:15 intensity:6];
    }
    
    ct%5==0?[g add_particle:[RocketLaunchParticle cons_x:[self position].x 
                                                      y:[self position].y 
                                                     vx:float_random(-7, 7) 
                                                     vy:float_random(-7, 7)]]:0;
    
    ct--;
    if (ct <= 0) {
        cur_mode = CopterMode_ToRemove;
        for(float i = 0; i < 5; i++) {
			[g add_particle:[BrokenCopterMachineParticle cons_x:[self position].x
															  y:[self position].y
															 vx:float_random(-5, 10)
															 vy:float_random(-10, 10)
														   pimg:i]];
            //[g add_particle:[BrokenMachineParticle cons_x:[self position].x y:[self position].y vx:float_random(-5, 10) vy:float_random(-10, 10)]];
        }
		[AudioManager playsfx:SFX_BIG_EXPLOSION];
        [GEventDispatcher push_event:[[GEvent cons_type:GEventType_BOSS1_DEFEATED] add_pt:g.player.position]];
		[g.score increment_score:1000];
		
		[g shake_for:40 intensity:10];
		
    }
}

-(void)trackingfire_left:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:90 y:80 z:131]];
    [self setScaleX:-1];
    
    if (rel_pos.x > TRACKINGFIRE_DIST) {
        rel_pos.x -= (DASHSPEED+2) * [Common get_dt_Scale];
        [self track_y];
        
    } else if (ct > 0) {
        ct--;
        [self track_y];
        
        if(ct%TRACKINGFIRE_RELOAD==0 && ct > TRACKINGFIRE_RELOAD) {
            CGPoint noz = [self get_nozzle];
            [LauncherRobot explosion:g at:noz];
            
            Vec3D rv = [VecLib cons_x:-1 y:0 z:0];
            rv = [VecLib normalize:rv];
            rv = [VecLib scale:rv by:TRACKINGFIRE_ROCKETSPEED];
            LauncherRocket *r = [[RelativePositionLauncherRocket cons_at:noz player:g.player.position vel:ccp(rv.x,rv.y)] set_remlimit:1300];
            
            [g add_gameobject:r];
			[AudioManager playsfx:SFX_ROCKET_LAUNCH];
            [self apply_recoil];
        }
        
    } else {
        rel_pos.x -= DASHSPEED * [Common get_dt_Scale];
    }
    
    actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
    if (rel_pos.x < -300) {
        [self get_random_action:Side_Left];
    }
}

-(void)rapidfire_right:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:320 y:80 z:131]];
    [self setScaleX:1];
    
    if (rel_pos.x < -DASHWAITDIST) {
        rel_pos.x += DASHSPEED * [Common get_dt_Scale];
    } else if (ct > 0) {
        ct--;
        if(ct%RAPIDFIRE_RELOAD_SPEED==0 && ct > RAPIDFIRE_RELOAD_SPEED) {
            CGPoint noz = [self get_nozzle];
            [LauncherRobot explosion:g at:noz];
            
            Vec3D rv = [VecLib cons_x:1 y:0 z:0];
            rv = [VecLib normalize:rv];
            rv = [VecLib scale:rv by:RAPIDFIRE_ROCKETSPEED];
            LauncherRocket *r = [[RelativePositionLauncherRocket cons_at:noz player:g.player.position vel:ccp(rv.x,rv.y)] set_remlimit:1300];
            
            [g add_gameobject:r];
			[AudioManager playsfx:SFX_ROCKET_LAUNCH];
            [self apply_recoil];
        }
    } else {
        rel_pos.x += DASHSPEED * [Common get_dt_Scale];
    }
    
    actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
    if (rel_pos.x > 400) {
        [self get_random_action:Side_Right];
    }
}

-(void)skyfire_left:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:94 y:38 z:131]];
    [self setScaleX:-1];
    [self setRotation:-45];
    
    ct++;
    if(ct%SKYFIRE_SPEED==0) {
        CGPoint noz = [self get_nozzle];
        [LauncherRobot explosion:g at:noz];
        
        Vec3D rv = [VecLib cons_x:-1 y:-1 z:0];
        rv = [VecLib normalize:rv];
        rv = [VecLib scale:rv by:2.5];
        LauncherRocket *r = [LauncherRocket cons_at:noz vel:ccp(rv.x,rv.y)];
        
        [g add_gameobject:r];
		[AudioManager playsfx:SFX_ROCKET_LAUNCH];
        [self apply_recoil];
    }
    
    if (rel_pos.x > -300) {
        rel_pos.x-=SLOWSPEED * [Common get_dt_Scale];
        actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
        
    } else {
        [self setRotation:0];
        [self get_random_action:Side_Left];
    }
}

-(void)left_dash:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:90 y:80 z:131]];
    [self setScaleX:-1];
    if (rel_pos.x > DASHWAITDIST) {
        rel_pos.x -= (DASHSPEED+2) * [Common get_dt_Scale];
        [self track_y];
        
    } else if (ct > 0) {
        ct--;
        [self track_y];
        
    } else {
        rel_pos.x -= DASHSPEED;
    }
    
    actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
    if (rel_pos.x < -300) {
        [self get_random_action:Side_Left];
    }
}

-(void)right_dash:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:320 y:80 z:131]];
    [self setScaleX:1];
    
    if (rel_pos.x < -DASHWAITDIST) {
        rel_pos.x += DASHSPEED * [Common get_dt_Scale];
        [self track_y];
    } else if (ct > 0) {
        ct--;
        [self track_y];
    } else {
        rel_pos.x += DASHSPEED * [Common get_dt_Scale];
    }
    
    actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
    
    if (rel_pos.x > 400) {
        [self get_random_action:Side_Right];
    }
}

-(void)intro_anim:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:94 y:38 z:131]];
    [self setScaleX:-1];
    
    if (rel_pos.x > -300) {
        rel_pos.x-=SLOWSPEED * [Common get_dt_Scale];
        actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
        
    } else {
        [self get_random_action:Side_Left];
    }
}

-(void)got_hit_flyoff:(GameEngineLayer*)g {
    [self setRotation:[self rotation]+25*[Common get_dt_Scale]];
    [self setOpacity:160];
    rel_pos.x += flyoffdir.x * [Common get_dt_Scale];
    rel_pos.y += flyoffdir.y * [Common get_dt_Scale];
    [self apply_rel_pos];
    ct++;
    ct%6==0?[g add_particle:[RocketLaunchParticle cons_x:[self position].x
                                                       y:[self position].y 
                                                      vx:-flyoffdir.x + float_random(-4, 4)
                                                      vy:-flyoffdir.y + float_random(-4, 4)
                                                   scale:float_random(1, 3)]]:0;
    
    if (rel_pos.x > 800 || rel_pos.x < -800 || rel_pos.y < -800 || rel_pos.y > 800) {
        [self setRotation:0];
        [self setOpacity:255];
        ct = 0;
        [self get_random_action:(rel_pos.x < 0?Side_Left:Side_Right)];
    }
}

-(void)killed_player:(GameEngineLayer*)g {}

-(void)track_y {
    actual_pos.y += SIG(player_pos.y+PLAYER_FOLLOW_OFFSET-actual_pos.y)*MIN(SLOWSPEED,ABS(player_pos.y+PLAYER_FOLLOW_OFFSET-actual_pos.y));
}

-(void)apply_rel_pos {
    actual_pos = CGPointAdd(rel_pos, player_pos);
}

-(CGPoint)get_nozzle {
    Vec3D dirvec = [VecLib cons_x:1 y:0 z:0];
    dirvec = [VecLib scale:dirvec by:100];
    if ([self scaleX] < 0) {
        dirvec.y += 40;
    } else {
        dirvec.y -=40;
    }
    
    dirvec = [VecLib scale:dirvec by:[self scaleX]];
    Vec3D rdirvec = [VecLib rotate:dirvec by_rad:-[Common deg_to_rad:[self rotation]]];
    
    CGPoint n = [VecLib transform_pt:[self position] by:rdirvec];
    
    return n;
}

-(void)apply_recoil {
    CGPoint noz = [self get_nozzle];
    Vec3D recoil_dir = [VecLib cons_x:noz.x-[self position].x y:noz.y-[self position].y z:0];
    recoil_dir = [VecLib normalize:recoil_dir];
    recoil_dir = [VecLib scale:recoil_dir by:-RECOIL_DIST];
    recoil_tar = ccp(recoil_dir.x,recoil_dir.y);
    recoil_ct = RECOIL_CT;
}

-(void)anim_recoil {
    if (recoil_ct > 0) {
        recoil_ct--;
        float pct = recoil_ct/RECOIL_CT;
        recoil = ccp(pct*(recoil_tar.x),pct*(recoil_tar.y));
        
    } else {
        recoil_tar = CGPointZero;
        recoil = CGPointZero;
    }
}

-(void)reset {
    cur_mode = CopterMode_ToRemove;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:actual_pos.x-40 y1:actual_pos.y-60 wid:80 hei:80];
}

-(void)set_bounds_and_ground:(GameEngineLayer*)g {
    float yl_min = g.player.position.y;
	Island *lowest = NULL;
	for (Island *i in g.islands) {
		if (i.endX > g.player.position.x && i.startX < g.player.position.x) {
			if (lowest == NULL || lowest.startY > i.startY) {
				lowest = i;
			}
		}
	}
	if (lowest != NULL) {
		yl_min = lowest.startY;
	}
    
	[g frame_set_follow_clamp_y_min:yl_min-500 max:yl_min+300];
	groundlevel = yl_min;
}

-(void)anim_arm {
    if (arm_dir) {
        arm_r--;
        arm_dir = arm_r<-20?!arm_dir:arm_dir;
    } else {
        arm_r++;
        arm_dir = arm_r>20?!arm_dir:arm_dir;
    }
    [arm setRotation:arm_r];
}

-(void)anim_vibration {
    vibration_theta+=VIBRATION_SPEED;
    vibration.y = VIBRATION_AMPLITUDE*sinf(vibration_theta);
}

-(void)cons_anims {
    body = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER]
                                  rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:BODY]];
    
    [self addChild:body];
    
    aux_prop = [CSF_CCSprite node];
    [aux_prop runAction:[self cons_anim:[NSArray arrayWithObjects:@"aux_prop_0",@"aux_prop_1",@"aux_prop_2",nil] speed:0.05]];
    [aux_prop setPosition:ccp(-92,0)];
    [self addChild:aux_prop];
    
    main_prop = [CSF_CCSprite node];
    [main_prop runAction:[self cons_anim:[NSArray arrayWithObjects:@"main_prop_0",@"main_prop_1",@"main_prop_2",@"main_prop_3",@"main_prop_4",nil] speed:0.05]];
    [main_prop setPosition:ccp(-5,85)];
    [self addChild:main_prop];
    
    main_nut = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER]
                                      rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"main_bolt"]];
    [main_nut setPosition:ccp(7,87)];
    [self addChild:main_nut];
    
    aux_nut = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER]
                                     rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"aux_bolt"]];
    [aux_nut setPosition:ccp(-92,-0)];
    [self addChild:aux_nut];
    
    arm = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER]
                                 rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:ARM]];
    [arm setPosition:ARM_DEFAULT_POSITION];
    [self addChild:arm];
    
    [body csf_setScale:DEFAULT_SCALE];
    [aux_prop csf_setScale:DEFAULT_SCALE];
    [main_prop csf_setScale:DEFAULT_SCALE];
    [arm csf_setScale:DEFAULT_SCALE];
    [main_nut csf_setScale:DEFAULT_SCALE];
    [aux_nut csf_setScale:DEFAULT_SCALE];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
}

-(void)check_should_render:(GameEngineLayer *)g {
	do_render = YES;
}

-(CCAction*)cons_anim:(NSArray*)a speed:(float)speed {
	CCTexture2D *texture = [Resource get_tex:TEX_ENEMY_COPTER];
	NSMutableArray *animFrames = [NSMutableArray array];
    for (NSString* k in a) [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:k]]];
    return [Common make_anim_frames:animFrames speed:speed];
}

@end

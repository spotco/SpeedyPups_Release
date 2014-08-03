#import "LauncherRobot.h"
#import "GameEngineLayer.h"
#import "CannonFireParticle.h"
#import "BrokenMachineParticle.h"
#import "MinionRobot.h"
#import "ScoreManager.h"
#import "JumpParticle.h"

@implementation LauncherRobot

#define TRACK_SPD 7
#define ANIM_NORMAL 1
#define ANIM_ANGRY 2
#define ANIM_DEAD 3

#define RECOIL_TIME 10.0
#define RECOIL_DIST 40
#define RELOAD 300

#define REMOVE_BEHIND_BUFFER 500

#define ROCKETSPEED 4

#define DEFAULT_SCALE 0.75

+(LauncherRobot*)cons_x:(float)x y:(float)y dir:(Vec3D)dir {
    return [[LauncherRobot node] cons_x:x y:y dir:dir];
}

+(void)explosion:(GameEngineLayer*)g at:(CGPoint)pt {
    for(int i = 0; i < 10; i++) {
        float r = ((float)i);
        r = r/5.0 * M_PI;
        float dvx = cosf(r)*10+float_random(0, 1);
        float dvy = sinf(r)*10+float_random(0, 1);
        [g add_particle:[RocketExplodeParticle cons_x:pt.x y:pt.y vx:dvx vy:dvy]];
    }
}

//launcher_dead
-(id)cons_x:(float)x y:(float)y dir:(Vec3D)tdir {
    body = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_LAUNCHER] 
                                  rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_LAUNCHER idname:@"launcher"]];
    dir = [VecLib cons_x:tdir.x y:tdir.y z:0];
    
    float tara = [self get_tar_angle_deg_self:[self position] tar:ccp([self position].x+dir.x,[self position].y+dir.y)];
    if (ABS(tara) > 90) {
        tara+=180;
        [body setScaleX:-DEFAULT_SCALE];
    } else {
        [body setScaleX:DEFAULT_SCALE];
    }
    [body setScaleY:DEFAULT_SCALE];
    starting_rot = tara;
    [self setRotation:tara];
    
    [self addChild:body];
    [self autolevel_set_position:ccp(x,y)];
    active = YES;
    return self;
}

-(void)autolevel_set_position:(CGPoint)pt {
	starting_pos = pt;
	[self setPosition:pt];
}

-(BOOL)has_hit_ground:(GameEngineLayer*)g rtv_ins:(CGPoint*)rtins rtv_isl:(Island**)rtisl {
    line_seg mv = [Common cons_line_seg_a:[self position] b:CGPointAdd([self position], ccp(vx,vy))];
    for (Island* i in g.islands) {
        line_seg li = [i get_line_seg];
        CGPoint ins = [Common line_seg_intersection_a:li b:mv];
        if (ins.x != [Island NO_VALUE]) {
			*rtins = ins;
			*rtisl = i;
            return YES;
        }
    }
    return NO;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!has_shadow) {
        [g add_gameobject:[ObjectShadow cons_tar:self]];
        has_shadow = YES;
    }
	if (sfx_rocket_launch_cooldown > 0) sfx_rocket_launch_cooldown--;
    
    if (busted) {
        if (current_island == NULL) {
			[self setRotation:self.rotation+25];
			CGPoint ins;
			Island *ins_isl;
			if ([self has_hit_ground:g rtv_ins:&ins rtv_isl:&ins_isl]) {
				current_island = ins_isl;
				[self setPosition:ins];
				vx = 0;
				vy = 0;
				
			} else {
				[self setPosition:CGPointAdd([self position], ccp(vx,vy))];
				vx = 0;
				vy -=0.5;
			
			}
        }
        return;
    }
    
    if ([self position].x + REMOVE_BEHIND_BUFFER < player.position.x) {
        return;
    }
    
    
    ct-=[Common get_dt_Scale];
    if (ct < 50) {
        ((int)ct)%5==0?[self toggle]:0;
    } else {
        [self set_anim:ANIM_NORMAL];
    }
    
    if (recoilanim_timer > 0) {
        recoilanim_timer--;
        float pct = (recoilanim_timer)/RECOIL_TIME;
        [self setPosition:ccp(
            pct*(RECOIL_DIST)*(-dir.x)+starting_pos.x,
            pct*(RECOIL_DIST)*(-dir.y)+starting_pos.y)
         ];
    } else {
        [self setPosition:starting_pos];
    }
    
    if (ct <= 0) {
        ct = RELOAD;
        
        CGPoint noz = [self get_nozzle];
        [LauncherRobot explosion:g at:noz];
        [g add_particle:[CannonFireParticle cons_x:noz.x y:noz.y]];
        
        Vec3D rv = [VecLib cons_x:dir.x y:dir.y z:0];
        rv = [VecLib scale:rv by:ROCKETSPEED];
        LauncherRocket *r = [LauncherRocket cons_at:noz vel:ccp(rv.x,rv.y)];
        
        [g add_gameobject:r];
        recoilanim_timer = RECOIL_TIME;
		
		if (CGPointDist([self position], player.position) < 1200) {
			[self play_rocketlaunch_sound];
		}
		
    }
    
    if (!player.dead && player.current_island == NULL && player.vy <= 0 && [Common hitrect_touch:[self get_hit_rect] b:[player get_jump_rect]]) {
		
		[g.score increment_multiplier:0.01];
		[g.score increment_score:20];
		
        busted = YES;
        [self set_anim:ANIM_DEAD];
        int ptcnt = arc4random_uniform(4)+4;
        for(float i = 0; i < ptcnt; i++) {
            [g add_particle:[BrokenMachineParticle cons_x:[self position].x y:[self position].y vx:float_random(-5, 5) vy:float_random(-3, 10)]];
        }
        [AudioManager playsfx:SFX_BOP];
        
        [MinionRobot player_do_bop:player g:g];
		[g add_particle:[JumpParticle cons_pt:player.position vel:ccp(player.vx,player.vy) up:ccp(player.up_vec.x,player.up_vec.y)]];
		[g shake_for:7 intensity:2];
		[g freeze_frame:6];
        
    } else if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        if (player.dashing || [player is_armored]) {
			
			[g.score increment_multiplier:0.01];
			[g.score increment_score:20];
			
            busted = YES;
            [self set_anim:ANIM_DEAD];
            int ptcnt = arc4random_uniform(4)+4;
            for(float i = 0; i < ptcnt; i++) {
                [g add_particle:[BrokenMachineParticle cons_x:[self position].x y:[self position].y vx:float_random(-5, 5) vy:float_random(-3, 10)]];
            }
            [AudioManager playsfx:SFX_ROCKBREAK];
            
            [MinionRobot player_do_bop:player g:g];
			
			[g shake_for:7 intensity:2];
			[g freeze_frame:6];
            
        }/* else if (!player.dead) {
            [player add_effect:[HitEffect init_from:[player get_default_params] time:40]];
            [DazedParticle init_effect:g tar:player time:40];
        }*/
        
    }
    
}

-(float)get_tar_angle_deg_self:(CGPoint)s tar:(CGPoint)t {
    //calc coord:       cocos2d coord:
    //+                    +
    //---0              0---
    //-                    -
    float ccwt = [Common rad_to_deg:atan2f(t.y-s.y, t.x-s.x)];
    return ccwt > 0 ? 180-ccwt : -(180-ABS(ccwt));
}

-(CGPoint)get_nozzle {
    CGPoint pos = [self position];
    Vec3D v = [VecLib cons_x:dir.x y:dir.y z:0];
    [VecLib scale:v by:110];
    pos = [VecLib transform_pt:pos by:v];
    return pos;
}

-(void)reset {
    [super reset];
    ct = 0;
    busted = NO;
    [self setRotation:starting_rot];
    current_island = NULL;
    [self set_anim:ANIM_NORMAL];
	[self setPosition:starting_pos];
}

-(void)toggle {
    animtoggle = animtoggle == ANIM_ANGRY?ANIM_NORMAL:ANIM_ANGRY;
    [self set_anim:animtoggle];
}

-(void)set_anim:(int)t {
    CGRect r = [FileCache get_cgrect_from_plist:TEX_ENEMY_LAUNCHER idname:
                (t==ANIM_NORMAL?@"launcher":
                 (t==ANIM_ANGRY?@"launcher_angry":
                  @"launcher_dead"))];
    [body setTextureRect:r];
}

-(void)set_active:(BOOL)t_active {active = t_active;}
-(HitRect)get_hit_rect {return [Common hitrect_cons_x1:[self position].x-50 y1:[self position].y-20 wid:100 hei:40];}


static int sfx_rocket_launch_cooldown = 0;

-(void)play_rocketlaunch_sound {
	if (sfx_rocket_launch_cooldown <= 0) {
		[AudioManager playsfx:SFX_ROCKET_LAUNCH];
		sfx_rocket_launch_cooldown = 10;
	}
}

@end


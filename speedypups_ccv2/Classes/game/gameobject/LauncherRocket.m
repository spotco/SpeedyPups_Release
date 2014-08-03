#import "LauncherRocket.h"
#import "LauncherRobot.h"
#import "JumpPadParticle.h"
#import "GameEngineLayer.h"
#import "HitEffect.h" 
#import "DazedParticle.h"
#import "ExplosionParticle.h"
#import "MinionRobot.h" 
#import "JumpParticle.h"

@implementation LauncherRocket

#define PARTICLE_FREQ 10
#define REMOVE_BEHIND_BUFFER 2000

#define DEFAULT_SCALE 0.75

-(id)set_scale:(float)sc {
	[self csf_setScale:sc];
	trail_scale = sc;
	return self;
}

-(CCAction*)cons_anim:(NSArray*)a speed:(float)speed {
	CCTexture2D *texture = [Resource get_tex:TEX_CANNONTRAIL];
	NSMutableArray *animFrames = [NSMutableArray array];
    for (NSString* k in a) [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_CANNONTRAIL idname:k]]];
    return  [Common make_anim_frames:animFrames speed:0.1];
}

+(LauncherRocket*)cons_at:(CGPoint)pt vel:(CGPoint)vel {
    return [[LauncherRocket node] cons_at:pt vel:vel];
}

-(id)cons_at:(CGPoint)pt vel:(CGPoint)vel {
    //[self setPosition:pt];
    actual_pos = pt;
    v = vel;
    active = YES;
    remlimit = -1;
    [self setRotation:[self get_tar_angle_deg_self:pt tar:ccp(pt.x+vel.x,pt.y+vel.y)]];
    [self set_scale:DEFAULT_SCALE];
    CCSprite *body = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_ROCKET]];
    [self addChild:body z:2];
    
    trail = [CCSprite node];
    [trail setScale:0.75];
    [trail setPosition:ccp(70/CC_CONTENT_SCALE_FACTOR(),0)];
    [trail runAction:[self cons_anim:[NSArray arrayWithObjects:@"1",@"2",@"3",@"4", nil] speed:0.1]];
    [self addChild:trail z:1];
	
	no_vibration = NO;
	
	already_removed = NO;
    
    return self;
}

-(LauncherRocket*)no_vibration {
	no_vibration = YES;
	return self;
}

-(void)update_position {
    actual_pos.x += v.x * [Common get_dt_Scale];
    actual_pos.y += v.y * [Common get_dt_Scale];
    [self setPosition:ccp(actual_pos.x+vibration.x,actual_pos.y+vibration.y)];
}

-(id)set_remlimit:(int)t {
    remlimit = t;
    return self;
}

-(void)update_vibration {
	if (no_vibration == NO) {
		vibration_ct+=0.2;
		vibration.y = 4*sinf(vibration_ct);
	}
}

-(BOOL)is_active {
	return (broken_ct <= 0);
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    [self update_vibration];
    [super update:player g:g];
    [self update_position];
    
    Vec3D dv = [VecLib cons_x:v.x y:v.y z:0];
    dv =[VecLib normalize:dv];
    dv =[VecLib scale:dv by:-1];
    dv =[VecLib scale:dv by:90];
    ct+=[Common get_dt_Scale];
    ((int)ct)%PARTICLE_FREQ==0?[g add_particle:[[RocketLaunchParticle cons_x:[self position].x+dv.x y:[self position].y+dv.y vx:-v.x vy:-v.y] set_scale:trail_scale]]:0;
    
    
    if ([self position].x + REMOVE_BEHIND_BUFFER < player.position.x) {
        kill = YES;
    } else if (remlimit != -1 && ct > remlimit) {
		[self remove_from:g];
		return;
    }
    
    if (kill || ![Common hitrect_touch:[self get_hit_rect] b:[g get_world_bounds]]) {
        //[g remove_gameobject:shadow];
        [g remove_gameobject:self];
        return;
        
    } else if (broken_ct > 0) {
        [trail setVisible:NO];
        [self setOpacity:150];
        [self setRotation:self.rotation+30];
        broken_ct--;
        if (broken_ct == 0) {
            [self remove_from:g];
            return;
        }
        
    } else if (broken_ct == 0 && !player.dead && !player.dashing && player.current_island == NULL && player.vy <= 0 && [Common hitrect_touch:[self get_hit_rect] b:[player get_jump_rect]]  && !player.dead) {
        [self flyoff:ccp(player.vx,player.vy) norm:6];
        [AudioManager playsfx:SFX_BOP];
        
        [MinionRobot player_do_bop:player g:g];
		[g add_particle:[JumpParticle cons_pt:player.position vel:ccp(player.vx,player.vy) up:ccp(player.up_vec.x,player.up_vec.y)]];
		[g shake_for:10 intensity:4];
		[g freeze_frame:6];
        
    } else if (broken_ct == 0 && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]  && !player.dead) {
        if (player.dashing || [player is_armored]) {
            [self flyoff:ccp(player.vx,player.vy) norm:7];
            [AudioManager playsfx:SFX_ROCKBREAK];
			[g shake_for:7 intensity:2];
			[g freeze_frame:6];
            
        } else if (!player.dead) {
            [player add_effect:[HitEffect cons_from:[player get_default_params] time:40]];
            [DazedParticle cons_effect:g tar:player time:40];
            [self remove_from:g];
            [g.get_stats increment:GEStat_ROBOT];
			[g shake_for:15 intensity:6];
			[g freeze_frame:6];
			
            return;
        }
        
        
    }
}

-(void)flyoff:(CGPoint)pv norm:(int)norm {
    broken_ct = 35;
    Vec3D pvec = [VecLib cons_x:pv.x y:pv.y z:0];
    if (norm > 0) {
        [VecLib normalize:pvec];
        [VecLib scale:pvec by:norm];
    }
    v.x = pvec.x;
    v.y = pvec.y;
}

-(void)remove_from:(GameEngineLayer*)g {
	if (already_removed) return;
	already_removed = YES;
    [AudioManager playsfx:SFX_EXPLOSION];
    [g add_particle:[ExplosionParticle cons_x:[self position].x y:[self position].y]];
    //[LauncherRobot explosion:g at:[self position]];
    //[g remove_gameobject:shadow];
    [g remove_gameobject:self];
}

-(float)get_tar_angle_deg_self:(CGPoint)s tar:(CGPoint)t {
    //calc coord:       cocos2d coord:
    //+                    +
    //---0              0---
    //-                    -
    float ccwt = [Common rad_to_deg:atan2f(t.y-s.y, t.x-s.x)];
    return ccwt > 0 ? 180-ccwt : -(180-ABS(ccwt));
}

-(int)get_render_ord{ return [GameRenderImplementation GET_RENDER_PLAYER_ON_FG_ORD];}
-(void)reset{[super reset];kill = YES;}
-(void)set_active:(BOOL)t_active {active = t_active;}
-(HitRect)get_hit_rect {
	//float hsc = trail_scale/DEFAULT_SCALE;
	float hsc = 1;
	return [Common hitrect_cons_x1:[self position].x-30*hsc y1:[self position].y-25*hsc wid:60*hsc hei:50*hsc];
}

@end


@implementation RelativePositionLauncherRocket

+(RelativePositionLauncherRocket*)cons_at:(CGPoint)pt player:(CGPoint)player vel:(CGPoint)vel {
    return [[RelativePositionLauncherRocket node] cons_at:pt player:player vel:vel];
}

-(id)cons_at:(CGPoint)pt player:(CGPoint)player vel:(CGPoint)vel {
    player_pos = player;
    [self setPosition:pt];
    rel_pos = ccp(pt.x-player.x,0);
    v = vel;
    [self update_position];
    [self csf_setScale:DEFAULT_SCALE];
    trail_scale = 0.75;
    body = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_ROCKET]];
    [self addChild:body z:2];
    
    trail = [CCSprite node];
    [trail setScale:0.75];
    [trail setPosition:ccp(70/CC_CONTENT_SCALE_FACTOR(),0)];
    [trail runAction:[self cons_anim:[NSArray arrayWithObjects:@"1",@"2",@"3",@"4", nil] speed:0.1]];
    [self addChild:trail z:1];
    
    active = YES;
    [self setRotation:[self get_tar_angle_deg_self:pt tar:ccp(pt.x+vel.x,pt.y+vel.y)]];
	
    return self;
}

-(id)set_homing {
	homing = YES;
	[body setTexture:[Resource get_tex:TEX_ENEMY_ROBOTBOSS]];
	[body setTextureRect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOTBOSS idname:@"homing_rocket"]];
	[body setScaleY:-body.scaleY];
	return self;
}

static float _beep_ct = 0;

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    player_pos = player.position;
    rel_pos.x += v.x * [Common get_dt_Scale];
    [super update:player g:g];
	
	if (homing && broken_ct == 0) {
		
		_beep_ct+=1;
		if (_beep_ct > 30) {
			[AudioManager playsfx:SFX_HOMING_BEEP];
			_beep_ct = 0;
		}
		
		float spd = [VecLib length:[VecLib cons_x:v.x y:v.y z:0]];
		Vec3D to_player = [VecLib scale:
						   [VecLib normalize:
							[VecLib cons_x:player.position.x - [self position].x y:player.position.y - [self position].y z:0]]
									 by:spd*0.03];
		v.x+=to_player.x;
		v.y+=to_player.y;
	
		Vec3D neu_v = [VecLib scale:[VecLib normalize:[VecLib cons_x:v.x y:v.y z:0]] by:spd];
		v.x = neu_v.x;
		v.y = neu_v.y;
		
		[self setRotation:[self get_tar_angle_deg_self:[self position] tar:ccp([self position].x+v.x,[self position].y+v.y)]];
		
		if ([self position].y + 2000 < player.position.y) {
			[self remove_from:g];
			return;
		}
	}
}

-(void)update_vibration {
    vibration_ct+=0.1;
    vibration.y = sinf(vibration_ct);
}

-(void)update_position {
    //only for horizontal relative, todo: make general
    //[self setPosition:ccp(rel_pos.x+player_pos.x,[self position].y+v.y)];
    actual_pos.x = rel_pos.x+player_pos.x;
    actual_pos.y = [self position].y+v.y * [Common get_dt_Scale];
    [self setPosition:ccp(actual_pos.x+vibration.x,actual_pos.y+vibration.y)];
}

@end

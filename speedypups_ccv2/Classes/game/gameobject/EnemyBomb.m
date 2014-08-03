#import "EnemyBomb.h"
#import "GameEngineLayer.h"
#import "Player.h" 
#import "ExplosionParticle.h" 
#import "HitEffect.h" 

@implementation BombSparkParticle
+(BombSparkParticle*)cons_pt:(CGPoint)pt v:(CGPoint)v {
    return [[BombSparkParticle spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]] cons_pt:pt v:v];
}
-(id)cons_pt:(CGPoint)pt v:(CGPoint)v {
    [self setPosition:pt];
	sc = 1;
    vel = v;
    ct = 15;
    [self csf_setScale:float_random(0.5, 0.9)];
    [self setColor:ccc3(251, 232, 52)];
    return self;
}
-(void)update:(GameEngineLayer *)g {
    [self setPosition:CGPointAdd([self position], ccp(vel.x*sc,vel.y*sc))];
    [self setOpacity:255*(ct/15.0)];
    ct--;
}
-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ABOVE_FG_ORD];
}
-(BOOL)should_remove {
    return ct <= 0;
}
-(id)set_scale:(float)scale {
	[self csf_setScale:scale];
	sc = scale;
	return self;
}
@end


@implementation EnemyBomb

#define DEFAULT_SCALE 1.5
+(EnemyBomb*)cons_pt:(CGPoint)pt v:(CGPoint)vel {
    return [[EnemyBomb node] cons_pt:pt v:vel];
}

-(id)cons_pt:(CGPoint)pt v:(CGPoint)vel {
    [self setPosition:pt];
    active = YES;
    body = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_BOMB]];
    [body setAnchorPoint:ccp(15/31.0,16/45.0)];
    [body setPosition:ccp(0,20)];
    
    v = vel;
    vtheta = 20;
    
    [self addChild:body];
    [body setScale:DEFAULT_SCALE];
    return self;
}
-(void)update:(Player *)player g:(GameEngineLayer *)g {
    ct++;
    if (knockout) {
        [self move:g];
        [body setOpacity:150];
        [body setRotation:body.rotation+25];
        if (ct > 20) {
            [g add_particle:[ExplosionParticle cons_x:[self position].x y:[self position].y]];
            
            [AudioManager playsfx:SFX_EXPLOSION];
            [g remove_gameobject:self];
        }
        
    } else if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]  && !player.dead) {
        if (player.dashing || [player is_armored]) {
            v = ccp(player.vx*1.4,player.vy*1.4);
            knockout = YES;
            ct = 0;
			[AudioManager playsfx:SFX_ROCKBREAK];
			
			[g shake_for:7 intensity:2];
			[g freeze_frame:6];
            
        } else {
            [player add_effect:[HitEffect cons_from:[player get_default_params] time:40]];
            [g add_particle:[ExplosionParticle cons_x:[self position].x y:[self position].y]];
            
            [AudioManager playsfx:SFX_EXPLOSION];
            [g remove_gameobject:self];
            [g.get_stats increment:GEStat_ROBOT];
			
			[g shake_for:15 intensity:6];
			[g freeze_frame:6];
        }
        
    } else if ([self has_hit_ground:g]) {
        [g add_particle:[ExplosionParticle cons_x:[self position].x y:[self position].y]];
        [AudioManager playsfx:SFX_EXPLOSION];
        [g remove_gameobject:self];
		
		[g shake_for:5 intensity:2];
		
        
    } else {
        [self move:g];
        v.y-=0.25*[Common get_dt_Scale];
        v.y = MAX(-10*[Common get_dt_Scale],v.y);
        ct%2==0?[g add_particle:[BombSparkParticle cons_pt:[self get_tip] v:ccp(float_random(-5,5),float_random(-5, 5))]]:0;
        [body setRotation:body.rotation+vtheta];
        
    }
}
-(void)move:(GameEngineLayer*)g {
    [self setPosition:CGPointAdd([self position], v)];
}
-(BOOL)has_hit_ground:(GameEngineLayer*)g {
    line_seg mv = [Common cons_line_seg_a:[self position] b:CGPointAdd([self position], v)];
    for (Island* i in g.islands) {
        line_seg li = [i get_line_seg];
        CGPoint ins = [Common line_seg_intersection_a:li b:mv];
        if (ins.x != [Island NO_VALUE]) {
            return YES;
        }
    }
    return NO;
}

#define TIPSCALE 70

-(CGPoint)get_tip {
    float arad = -[Common deg_to_rad:[body rotation]]+45;
    return ccp([self position].x+cosf(arad)*TIPSCALE*0.65,[self position].y+sinf(arad)*TIPSCALE);
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-20 y1:[self position].y-20 wid:40 hei:40];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_PLAYER_ON_FG_ORD];
}
@end

@implementation RelativePositionEnemyBomb

+(RelativePositionEnemyBomb*)cons_pt:(CGPoint)pt v:(CGPoint)vel player:(CGPoint)player {
	return [[RelativePositionEnemyBomb node] cons_pt:pt v:vel player:player];
}

-(id)cons_pt:(CGPoint)pt v:(CGPoint)vel player:(CGPoint)player {
	player_rel_pos = ccp(pt.x - player.x,pt.y - player.y);
	bg_to_front_ct = 0;
	KILL = NO;
	[super cons_pt:pt v:vel];
	return self;
}

#define CT 45.0
#define MINSCALE 0.35
-(id)do_bg_to_front_anim {
	bg_to_front_ct = CT;
	[self csf_setScale:MINSCALE];
	return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
	if (KILL) {
		[g remove_gameobject:self];
		return;
	}
	if (bg_to_front_ct > 0) bg_to_front_ct--;
	[self csf_setScale:((1-MINSCALE)*((CT-bg_to_front_ct)/CT)+MINSCALE)];
	
	[super update:player g:g];
}

-(void)move:(GameEngineLayer*)g {
	player_rel_pos.x += v.x * [Common get_dt_Scale];
    [self setPosition:ccp(g.player.position.x+player_rel_pos.x,[self position].y+v.y * [Common get_dt_Scale])];
}

-(void)reset {
	KILL = YES;
}

@end

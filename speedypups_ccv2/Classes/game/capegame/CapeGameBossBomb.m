#import "CapeGameBossBomb.h"
#import "Resource.h"
#import "Common.h"
#import "EnemyBomb.h"
#import "CapeGamePlayer.h"
#import "ExplosionParticle.h"
#import "AudioManager.h"

@implementation CapeGameBossBomb
+(CapeGameBossBomb*)cons_pos:(CGPoint)pos {
	return [[CapeGameBossBomb spriteWithTexture:[Resource get_tex:TEX_ENEMY_BOMB]] cons_pos:pos];
}

-(id)cons_pos:(CGPoint)pos {
	[super setPosition:pos];
	[self setAnchorPoint:ccp(15/31.0,16/45.0)];
	out_ct = 0;
	return self;
}

-(void)update:(CapeGameEngineLayer *)g {
	
	if (out_ct > 0) {
		out_ct-=[Common get_dt_Scale];
		[super setPosition:CGPointAdd(self.position, ccp(out_vel.x*[Common get_dt_Scale],out_vel.y*[Common get_dt_Scale]))];
		[self setOpacity:190];
		[self setRotation:self.rotation+10*[Common get_dt_Scale]];
		
		if (out_ct <= 0) {
			[g add_particle:[ExplosionParticle cons_x:[self position].x y:[self position].y]];
			[g remove_gameobject:self];
			[AudioManager playsfx:SFX_EXPLOSION];
		}
		
	} else if ([Common hitrect_touch:[self get_hit_rect] b:g.player.get_hitrect]) {
		if (g.player.is_rocket) {
			[AudioManager playsfx:SFX_ROCKBREAK];
			out_ct = 25;
			out_vel = ccp(float_random(3, 5),g.player.vy*0.4);
			
			[g shake_for:10 intensity:4];
			[g freeze_frame:6];
			
		} else {
			[g add_particle:[ExplosionParticle cons_x:[self position].x y:[self position].y]];
			[g remove_gameobject:self];
			[AudioManager playsfx:SFX_EXPLOSION];
			[g do_get_hit];
			
			[g shake_for:15 intensity:6];
			[g freeze_frame:6];
		}
		
	} else if (self.position.x < -100) {
		[g remove_gameobject:self];
	
	} else {
		[self setRotation:self.rotation+6*[Common get_dt_Scale]];
		[super setPosition:CGPointAdd(self.position, ccp(-3.5*[Common get_dt_Scale],0))];
		[g add_particle:[[BombSparkParticle cons_pt:[self get_tip] v:ccp(float_random(-5,5),float_random(-5, 5))] set_scale:0.4]];
	}
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-20 y1:[self position].y-20 wid:40 hei:40];
}

#define TIPSCALE 30
-(CGPoint)get_tip {
    float arad = -[Common deg_to_rad:[self rotation]]+45;
    return ccp([self position].x+cosf(arad)*TIPSCALE*0.65,[self position].y+sinf(arad)*TIPSCALE);
}

-(void)setPosition:(CGPoint)position{}
@end


@implementation CapeGameBossPowerupRocket
+(CapeGameBossPowerupRocket*)cons_pos:(CGPoint)pos {
	return [[CapeGameBossPowerupRocket spriteWithTexture:[Resource get_tex:TEX_ITEM_SS]
													rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"pickup_rocket"]]
			cons_pos:pos];
}

-(id)cons_pos:(CGPoint)pos {
	[super setPosition:pos];
	return self;
}

-(void)update:(CapeGameEngineLayer *)g {
	rotation_theta+=0.01*[Common get_dt_Scale];
	[self setRotation:sinf(rotation_theta)*15];
	[super setPosition:CGPointAdd(self.position, ccp(-3.5*[Common get_dt_Scale],0))];
	
	if ([Common hitrect_touch:[self get_hit_rect] b:g.player.get_hitrect]) {
		[g remove_gameobject:self];
		[AudioManager playsfx:SFX_POWERUP];
		[g do_powerup_rocket];
		
	}
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-30 y1:[self position].y-30 wid:60 hei:60];
}

-(void)setPosition:(CGPoint)position{}

@end
#import "VolleyRobotBossFistProjectile.h"
#import "GameEngineLayer.h"
#import "ExplosionParticle.h"
#import "Player.h" 
#import "HitEffect.h"
#import "EnemyBomb.h"

#define MODE_LINE 0
#define MODE_PARABOLA_A 1
#define MODE_PARABOLA_A2 2
#define MODE_PARABOLA_AT_CAT 3
#define MODE_PARABOLA_B 4
#define MODE_PARABOLA_CAT_LEFT 5

#define ROBOT_DEFAULT_POS ccp(725,0)

@implementation VolleyRobotBossFistProjectile
@synthesize direction;

+(VolleyRobotBossFistProjectile*)cons_g:(GameEngineLayer*)g relpos:(CGPoint)relpos tarpos:(CGPoint)tarpos time:(float)time groundlevel:(float)groundlevel {
	return [[VolleyRobotBossFistProjectile spriteWithTexture:[Resource get_tex:TEX_ENEMY_BOMB]]
			cons_g:g relpos:relpos tarpos:tarpos time:time groundlevel:groundlevel];
}

-(id)cons_g:(GameEngineLayer*)g relpos:(CGPoint)_relpos tarpos:(CGPoint)_tarpos time:(float)time groundlevel:(float)_groundlevel {
	time_total = time;
	time_left = time;
	startpos = _relpos;
	tarpos = _tarpos;
	groundlevel = _groundlevel;
	
	[self setAnchorPoint:ccp(15/31.0,16/45.0)];
	[self csf_setScale:3];
	
	mode = MODE_LINE;
	
	[self setPosition:CGPointAdd(ccp(g.player.position.x,groundlevel), startpos)];
	
	self.active = YES;
	return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
	time_left -= [Common get_dt_Scale];
	
	float time_pct = time_left/time_total;
	float x = tarpos.x + (startpos.x - tarpos.x)*time_pct;
	float y;
	
	if (mode == MODE_PARABOLA_A) {
		y = 3.39*x - 0.0047*x*x; //quadratic fit {0,0}, {585,350}, {250,550}
		
	} else if (mode == MODE_PARABOLA_A2) {
		y = 3.16179*x - 0.003847*x*x; //quadratic fit {0,0}, {690,350}, {250,550}
		
	} else if (mode == MODE_PARABOLA_AT_CAT) {
		y = -0.0115646*x*x + 17.649*x - 6017.35; //quadratic fit {900,500}, {585,350}, {725,700}
		
	} else if (mode == MODE_PARABOLA_B) {
		y = -0.00995*x*x - 4.74*x; //quadratic fit {-385,350}, {-200,550}, {0,0}
		
	} else if (mode == MODE_PARABOLA_CAT_LEFT) {
		y = -0.014454*x*x - 16.4014*x - 3898.29; //quadratic fit {-395,325}, {-550,750}, {-700,500}
		
	} else {
		y = tarpos.y + (startpos.y - tarpos.y)*time_pct;
	
	}
	
	[self setPosition:CGPointAdd(ccp(g.player.position.x,groundlevel), ccp(x,y))];
	
	self.rotation += [Common get_dt_Scale] * (direction == RobotBossFistProjectileDirection_AT_PLAYER ? 5 : 12);
	
	[g add_particle:[BombSparkParticle cons_pt:[self get_tip] v:ccp(float_random(-5,5),float_random(-5, 5))]];
	
	if (direction == RobotBossFistProjectileDirection_AT_PLAYER && !player.dead) {
		if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]] && (player.dashing || [player is_armored])) {
            time_total = 55;
			time_left = 55;
			startpos = ccp(x,y);
			
			tarpos = bosspos;
			
			direction = RobotBossFistProjectileDirection_AT_BOSS;
			[self mode_line];
			[AudioManager playsfx:SFX_ROCKBREAK];
			
			[g shake_for:10 intensity:4];
			[g freeze_frame:6];
			
		} else if ([Common hitrect_touch:[self get_small_hit_rect] b:[player get_hit_rect]]) {
            [player add_effect:[HitEffect cons_from:[player get_default_params] time:40]];
			[self explosion_effect:g];
            [AudioManager playsfx:SFX_EXPLOSION];
            [g remove_gameobject:self];
            [g.get_stats increment:GEStat_ROBOT];
			
			[g shake_for:15 intensity:6];
			[g freeze_frame:6];
		}
		
	}
}

-(id)set_boss_pos:(CGPoint)pos {
	bosspos = pos;
	return self;
}

-(id)set_startpos:(CGPoint)_startpos tarpos:(CGPoint)_tarpos time_left:(float)_time_left time_total:(float)_time_total {
	startpos = _startpos;
	tarpos = _tarpos;
	time_left = _time_left;
	time_total = _time_total;
	return self;
}

-(float)time_left {
	return time_left;
}

-(id)mode_parabola_a {
	mode = MODE_PARABOLA_A;
	return self;
}

-(id)mode_parabola_a2 {
	mode = MODE_PARABOLA_A2;
	return self;
}

-(id)mode_parabola_b {
	mode = MODE_PARABOLA_B;
	return self;
}

-(id)mode_parabola_at_cat {
	mode = MODE_PARABOLA_AT_CAT;
	return self;
}

-(id)mode_parabola_at_cat_left {
	mode = MODE_PARABOLA_CAT_LEFT;
	return self;
}

-(id)mode_line {
	mode = MODE_LINE;
	return self;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-40 y1:[self position].y-40 wid:80 hei:80];
}

-(HitRect)get_small_hit_rect {
	return [Common hitrect_cons_x1:[self position].x-20 y1:[self position].y-20 wid:40 hei:40];
}

-(void)force_remove {
	time_left = 0;
}

-(BOOL)should_remove {
	return time_left <= 0;
}

-(void)do_remove:(GameEngineLayer *)g {
	[self explosion_effect:g];
}

-(void)explosion_effect:(GameEngineLayer*)g {
	[g add_particle:[[ExplosionParticle cons_x:[self position].x y:[self position].y] set_scale:1.5]];
}

#define TIPSCALE 115
-(CGPoint)get_tip {
    float arad = -[Common deg_to_rad:[self rotation]]+45;
    return ccp([self position].x+cosf(arad)*TIPSCALE*0.65,[self position].y+sinf(arad)*TIPSCALE);
}

-(void)check_should_render:(GameEngineLayer *)g { do_render = YES; }

@end

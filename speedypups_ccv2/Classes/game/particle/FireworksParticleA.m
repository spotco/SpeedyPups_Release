#import "FireworksParticleA.h"
#import "GameEngineLayer.h"
#import "ObjectPool.h"

@implementation SubFireworksParticleA

-(BOOL)is_batched_sprite {
	return YES;
}
-(NSString*)get_batch_sprite_tex_key {
	return TEX_PARTICLES;
}

#define SUBCT 25.0
+(SubFireworksParticleA*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    //SubFireworksParticleA* p = [SubFireworksParticleA spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]];
    SubFireworksParticleA *p = [ObjectPool depool:[SubFireworksParticleA class]];
	//[p setTexture:[Resource get_tex:TEX_PARTICLES]];
	//[p setTextureRect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]];
	
	[p setDisplayFrame:[CCSpriteFrame frameWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]]];
	
	p.position = ccp(x,y);
    [p cons_vx:vx vy:vy];
    return p;
}
-(void)repool {
	if ([self class] == [SubFireworksParticleA class]) [ObjectPool repool:self class:[SubFireworksParticleA class]];
}
-(void)cons_vx:(float)tvx vy:(float)tvy {
    vx = tvx;
    vy = tvy;
    ct = SUBCT;
    [self setColor:ccc3(251, 232, 52)];
    [self csf_setScale:float_random(0.2, 0.7)];
	[self setOpacity:255];
}
//ccc3(251,232,52)->ccc3(255,156,0)
-(void)update:(GameEngineLayer *)g {
    [self setPosition:ccp([self position].x+vx,[self position].y+vy)];
    ct--;
    [self setOpacity:((int)(ct/SUBCT*255))];
	float pct = ct/SUBCT;
	[self setColor:[Common color_from:ccc3(251,245,52) to:ccc3(255,156,0) pct:1-pct]];
}
-(BOOL)should_remove {
    return ct <= 0;
}
@end


@implementation FireworksParticleA

-(BOOL)is_batched_sprite {
	return YES;
}
-(NSString*)get_batch_sprite_tex_key {
	return TEX_PARTICLES;
}

+(FireworksParticleA*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy ct:(int)ct {
    //FireworksParticleA* p = [FireworksParticleA spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]];
	FireworksParticleA *p = [ObjectPool depool:[FireworksParticleA class]];
	//[p setTexture:[Resource get_tex:TEX_PARTICLES]];
	//[p setTextureRect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]];
	
	[p setDisplayFrame:[CCSpriteFrame frameWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]]];
	
	p.position = ccp(x,y);
    [p cons_vx:vx vy:vy ct:ct];
    return p;
}

-(void)repool {
	if ([self class] == [FireworksParticleA class]) [ObjectPool repool:self class:[FireworksParticleA class]];
}

-(void)cons_vx:(float)tvx vy:(float)tvy ct:(int)tct{
    vx = tvx;
    vy = tvy;
    ct = tct;
    [self setColor:ccc3(251, 245, 52)];
	[self setOpacity:255];
}

static int _time_since_last_sfx_play = 0;

-(void)update:(GameEngineLayer*)g {
    [self setPosition:ccp([self position].x+vx,[self position].y+vy)];
    ct--;
	if (_time_since_last_sfx_play > 0) {
		_time_since_last_sfx_play--;
	}
	
    if (ct == 0) {
		if (_time_since_last_sfx_play <= 0) {
			[AudioManager playsfx:SFX_FIREWORKS];
			_time_since_last_sfx_play = 10;
		}
        for (float i = 0; i < M_PI * 2; i+= (M_PI*2)/14) {
            [g add_particle:[SubFireworksParticleA cons_x:[self position].x
														y:[self position].y
													   vx:cosf(i+float_random(-0.2, 0.2))*6
													   vy:sinf(i+float_random(-0.2, 0.2))*6]];
			
            [g add_particle:[SubFireworksParticleA cons_x:[self position].x
														y:[self position].y
													   vx:cosf(i+float_random(-0.2, 0.2))*4
													   vy:sinf(i+float_random(-0.2, 0.2))*4]];
			
            [g add_particle:[SubFireworksParticleA cons_x:[self position].x
														y:[self position].y
													   vx:cosf(i+float_random(-0.2, 0.2))*2
													   vy:sinf(i+float_random(-0.2, 0.2))*2]];
			
            [g add_particle:[SubFireworksParticleA cons_x:[self position].x
														y:[self position].y
													   vx:cosf(i+float_random(-0.2, 0.2))*0.5
													   vy:sinf(i+float_random(-0.2, 0.2))*0.5]];
        }
    }
}
-(BOOL)should_remove {
    return ct <= 0;
}
-(int)get_render_ord {
	return [GameRenderImplementation GET_BEHIND_GAMEOBJ_ORD];
}
@end

@implementation FireworksGroundFlower

#define FWGFCT 60.0
+(FireworksGroundFlower*)cons_pt:(CGPoint)pt {
	return [[FireworksGroundFlower spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]] cons_pt:pt];
}
-(id)cons_pt:(CGPoint)pt {
	ct = FWGFCT;
	vel = ccp(float_random(-0.5,0.5),float_random(9,10));
	acel = ccp(float_random(-0.1,0.1),float_random(-0.2, -0.1));
	[self csf_setScale:float_random(0.4, 0.9)];
	[self csf_setScaleY:[self scaleY]*1.25];
	[self setColor:[Common color_from:ccc3(251,232,52) to:ccc3(255,156,0) pct:1-ct/FWGFCT]];
	[self setPosition:CGPointAdd(pt, ccp(float_random(-5, 5),0))];
	return self;
}
-(void)update:(GameEngineLayer*)g {
	ct--;
	[self setPosition:CGPointAdd([self position], vel)];
	[self setColor:[Common color_from:ccc3(251,232,52) to:ccc3(255,156,0) pct:1-ct/FWGFCT]];
	[self setOpacity:
	 ct>10?150+105*(ct/FWGFCT):171*(ct/10.0)
	];

	[self setRotation:[VecLib get_rotation:[VecLib cons_x:vel.x y:vel.y z:0] offset:-90]];
	
	vel = CGPointAdd(vel, acel);
	
}
-(int)get_render_ord {
	return [GameRenderImplementation GET_BEHIND_GAMEOBJ_ORD];
}
-(BOOL)should_remove {
    return ct <= 0;
}
@end

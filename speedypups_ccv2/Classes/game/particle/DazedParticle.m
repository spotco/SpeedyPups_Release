#import "DazedParticle.h"
#import "GameEngineLayer.h"

@implementation DazedParticle

+(DazedParticle*)cons_x:(float)x y:(float)y theta:(float)theta time:(int)time tracking:(id<PhysicsObject>)t {
    return [[DazedParticle spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]] cons_x:x y:y t:theta time:time tracking:t];
}

+(DazedParticle*)cons_x:(float)x y:(float)y theta:(float)theta time:(int)time tracking_sprite:(CCSprite*)t {
    return [[DazedParticle spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]] cons_x:x y:y t:theta time:time tracking_sprite:t];
}

+(void)cons_effect:(GameEngineLayer *)g tar:(id<PhysicsObject>)tar time:(int)time {
    float x = tar.position.x;
    float y = tar.position.y+60*(tar.current_island != NULL?tar.last_ndir:1);
    
    [g add_particle:[DazedParticle cons_x:x y:y theta:0 time:time tracking:tar]];
    [g add_particle:[DazedParticle cons_x:x y:y theta:M_PI/2 time:time tracking:tar]];
    [g add_particle:[DazedParticle cons_x:x y:y theta:M_PI time:time tracking:tar]];
    [g add_particle:[DazedParticle cons_x:x y:y theta:M_PI*1.5 time:time tracking:tar]];
	tar.current_swingvine = NULL;
    
}

+(void)cons_effect:(id)particlelayer sprite:(CCSprite *)tar time:(int)time { //lel hax
    float x = tar.position.x;
    float y = tar.position.y+60;
    
    [particlelayer add_particle:[DazedParticle cons_x:x y:y theta:0 time:time tracking_sprite:tar]];
    [particlelayer add_particle:[DazedParticle cons_x:x y:y theta:M_PI/2 time:time tracking_sprite:tar]];
    [particlelayer add_particle:[DazedParticle cons_x:x y:y theta:M_PI time:time tracking_sprite:tar]];
    [particlelayer add_particle:[DazedParticle cons_x:x y:y theta:M_PI*1.5 time:time tracking_sprite:tar]];
}

-(DazedParticle*)cons_x:(float)x y:(float)y t:(float)t time:(int)time tracking_sprite:(CCSprite*)tracking { 
    [self setPosition:ccp(x,y)];
    [self csf_setScale:0.3];
    [self setColor:ccc3(255, 255, 0)];
    cx = x;
    cy = y;
    ct = time;
    theta = t;
    tar = NULL;
	tarsprite = tracking;
    return self;
}

-(DazedParticle*)cons_x:(float)x y:(float)y t:(float)t time:(int)time tracking:(id<PhysicsObject>)tracking {
    [self setPosition:ccp(x,y)];
    [self csf_setScale:0.6];
    [self setColor:ccc3(255, 255, 0)];
    cx = x;
    cy = y;
    ct = time;
    theta = t;
    tar = tracking;
    return self;
}

-(void)update:(GameEngineLayer *)g {
    ct--;
    theta+=0.2;
    
    if (tar != NULL) {
        cx = tar.position.x;
        cy = tar.position.y+60*(tar.current_island != NULL?tar.last_ndir:1);
		[self setPosition:ccp(cos(theta)*40+cx,sin(theta)*10+cy)];
		
    } else if (tarsprite != NULL) {
        cx = tarsprite.position.x;
        cy = tarsprite.position.y + 30;
		[self setPosition:ccp(cos(theta)*20+cx,sin(theta)*5+cy)];
	}
    
}

-(BOOL)should_remove {
    return ct<=0;
}

-(int)get_render_ord { 
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD]+1; 
}

@end

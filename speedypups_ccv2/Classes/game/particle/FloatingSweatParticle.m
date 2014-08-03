#import "FloatingSweatParticle.h"
#import "FileCache.h"

@implementation FloatingSweatParticle

/*
-(void)add_floating_particle:(GameEngineLayer*)g {
    if (particlectr >= 10) {
        particlectr = 0;
        float pvx;
        if (arc4random_uniform(2) == 0) {
            pvx = float_random(4, 6);
        } else {
            pvx = float_random(-4, -6);
        }
        [g add_particle:[FloatingSweatParticle cons_x:position_.x+6 y:position_.y+29 vx:pvx+vx vy:float_random(3, 6)+vy]];
    } else {
        particlectr++;
    }
}
*/
 
+(FloatingSweatParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    FloatingSweatParticle* p = [FloatingSweatParticle spriteWithTexture:[Resource get_tex:TEX_PARTICLES] rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"grey_particle"]];
    p.position = ccp(x,y);
    [p cons_vx:vx vy:vy];
    return p;
}

-(void)cons_vx:(float)tvx vy:(float)tvy {
    vx = tvx;
    vy = tvy;
    [self csf_setScale:float_random(0.5, 0.9)];
    ct = 20;
    [self setColor:ccc3(255, 255, 255)];
}

-(void)update:(GameEngineLayer *)g {
    [super update:g];
    vy--;
}

@end

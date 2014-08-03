#import "TreatPickup.h"
#import "RotateFadeOutParticle.h"
#import "GameEngineLayer.h"

@implementation TreatPickup {
	float ct;
}

+(TreatPickup*)cons_pt:(CGPoint)pt {
    return [[TreatPickup node] init_pt:pt];
}

-(id)init_pt:(CGPoint)pt {
    [self setPosition:pt];
    active = YES;
    self.img = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ITEM_SS]
									  rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"treat"]];
    [self.img setScale:1.2];
    [self addChild:self.img];
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
	[super update:player g:g];
	ct+=[Common get_dt_Scale];
	if (ct >= 2 && self.active) {
		if (CGPointDist(self.position, player.position) < 5000) {
			[g add_particle:(Particle*)[[[[RotateFadeOutParticle
							 cons_tex:[Resource get_tex:TEX_PARTICLES]
							 rect:[FileCache get_cgrect_from_plist:TEX_PARTICLES idname:@"star"]]
							set_vr:float_random(-15, 15)]
						set_ctmax:30]
					pos:ccp(self.position.x + float_random(-60, 60),self.position.y + float_random(-60, 60))]];
		}
		
		ct = 0;
	}
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-15 y1:[self position].y-15 wid:30 hei:30];
}

-(void)hit {
	[AudioManager playsfx:SFX_POWERUP];
    [GEventDispatcher push_event:[GEvent cons_type:GEventType_GET_TREAT]];
    active = NO;
}

@end

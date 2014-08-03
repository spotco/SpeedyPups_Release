#import "ItemUseUIAnimation.h"
#import "ShopBuyBoneFlyoutParticle.h"
#import "UserInventory.h"

@interface ItemUseFlyoutParticle : ShopBuyBoneFlyoutParticle
@end

@implementation ItemUseFlyoutParticle
+(ItemUseFlyoutParticle*)cons_pt:(CGPoint)pt vel:(CGPoint)vel {
	return [[ItemUseFlyoutParticle node] cons_pt:pt vel:vel];
}
-(void)set_body {
	CCSprite *sub = [CCSprite node];
	TexRect *tr = [GameItemCommon texrect_from:[UserInventory get_current_gameitem]];
	sub.texture = tr.tex;
	sub.textureRect = tr.rect;
	[sub setScale:0.6];
	[self addChild:sub];
}
@end

@implementation ItemUseUIAnimation

+(ItemUseUIAnimation*)cons_around:(CGPoint)pt {
	return (ItemUseUIAnimation*)[[ItemUseUIAnimation node] pos:pt];
}

-(id)init {
	self = [super init];
	particles = [NSMutableArray array];
	for (float i = 0; i < 2*M_PI-0.1; i+=M_PI/5) {
		CGPoint vel = ccp(sinf(i),cosf(i));
		float scale = float_random(2, 4);
		[self add_particle:[ItemUseFlyoutParticle cons_pt:CGPointZero vel:ccp(vel.x*scale,vel.y*scale)]];
	}
	ct = 1;
	return self;
}

-(void)update {
	NSMutableArray *toremove = [NSMutableArray array];
    for (Particle *i in particles) {
        [i update:(id)self];
        if ([i should_remove]) {
            [self removeChild:i cleanup:YES];
            [toremove addObject:i];
        }
    }
	[particles removeObjectsInArray:toremove];
	
	if (particles.count == 0) {
		ct = 0;
	}
}

-(void)add_particle:(Particle*)p {
	[self addChild:p];
	[particles addObject:p];
}

@end

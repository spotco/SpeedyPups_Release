#import "OneUpObject.h"
#import "OneUpParticle.h"
#import "GameEngineLayer.h"
#import "ScoreManager.h"

#import "UILayer.h"

@implementation OneUpObject {
	BOOL only_appear_if_below_threshold;
}


+(OneUpObject*)cons_pt:(CGPoint)pt {
	return [[OneUpObject spriteWithTexture:[Resource get_tex:TEX_ITEM_SS] rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"1upobject"]] cons_pt:pt];
}

-(void)set_only_appear_if_below_threshold {
	only_appear_if_below_threshold = true;
}

-(id)cons_pt:(CGPoint)pt {
	[self setPosition:pt];
	active = YES;
	[self csf_setScale:0.75];
	only_appear_if_below_threshold = false;
	return self;
}
-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-30 y1:[self position].y-30 wid:60 hei:60];
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
	_g = g;
	if (only_appear_if_below_threshold) {
		if (active && [g get_lives] >= 10) {
			active = false;
		}
	}
	
	[super update:player g:g];
}

-(void)hit {
	[_g.score increment_multiplier:0.1];
	[_g.score increment_score:50];
	[_g incr_lives];
	//[_g add_particle:[OneUpParticle cons_pt:[_g.player get_center]]];
	[[_g get_ui_layer] start_oneup_anim];
	[AudioManager playsfx:SFX_1UP];
	active = NO;
}

-(void)reset {
    [self setPosition:initial_pos];
    follow = NO;
    vx = 0;
    vy = 0;
	active = YES;
}
@end

#import "CapeGameBone.h"
#import "Resource.h"
#import "Common.h"
#import "CapeGamePlayer.h"
#import "AudioManager.h"
#import "FileCache.h"
#import "DogBone.h"
#import "GameEngineLayer.h"
#import "ScoreManager.h"
#import "Vec3D.h"
#import "OneUpParticle.h"
#import "CapeGameUILayer.h"

@implementation CapeGameBone
+(CapeGameBone*)cons_pt:(CGPoint)pt {
	return [[CapeGameBone node] cons_pt:pt];
}

-(id)cons_pt:(CGPoint)pt {
	[self setTexture:[Resource get_tex:TEX_ITEM_SS]];
	[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"goldenbone"]];
	[self setPosition:pt];
	active = YES;
	follow = NO;
	return self;
}

-(void)update:(CapeGameEngineLayer *)g {
	if (!active) return;
	
	float dist = [Common distanceBetween:[self position] and:g.player.position];
	
	if (dist > 400 || !active) {
		[self setVisible:NO];
	} else {
		[self setVisible:YES];
	}
	
	if (!follow && dist < 85) {
        follow = YES;
		
	} else if (follow) {
        Vec3D vel = [VecLib cons_x:g.player.position.x-[self position].x y:g.player.position.y-[self position].y z:0];
        vel = [VecLib normalize:vel];
        vel = [VecLib scale:vel by:MAX(12,sqrtf(powf(g.player.vx, 2) + powf(g.player.vy, 2))*1.2)];
        [self setPosition:ccp([self position].x + vel.x, [self position].y + vel.y)];
	}
	
	if ([Common hitrect_touch:[[g player] get_hitrect] b:[self get_hitrect]]) {
		[self setVisible:NO];
		[self on_hit:g];
		active = NO;
	}
}
-(void)on_hit:(CapeGameEngineLayer *)g {
	[g collect_bone:[self convertToWorldSpace:ccp(0,0)]];
	[g.get_main_game.score increment_multiplier:0.005];
	[g.get_main_game.score increment_score:10];
	[DogBone play_collect_sound:g.get_main_game];
}

-(HitRect)get_hitrect {
	return [Common hitrect_cons_x1:[self position].x-10 y1:[self position].y-10 wid:20 hei:20];
}
@end

@implementation CapeGameOneUpObject
+(CapeGameOneUpObject*)cons_pt:(CGPoint)pt {
	return [[CapeGameOneUpObject node] cons_pt:pt];
}
-(id)cons_pt:(CGPoint)pt {
	[self setTexture:[Resource get_tex:TEX_ITEM_SS]];
	[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"1upobject"]];
	[self csf_setScale:0.5];
	[self setPosition:pt];
	active = YES;
	follow = NO;
	return self;
}
-(void)on_hit:(CapeGameEngineLayer *)g {
	OneUpParticle *p = [OneUpParticle cons_pt:g.player.position];
	[p csf_setScale:0.5];
	[g add_particle:p];
	[AudioManager playsfx:SFX_1UP];
	[[g get_main_game] incr_lives];
}
@end

@implementation CapeGameTreatObject
+(CapeGameTreatObject*)cons_pt:(CGPoint)pt {
	return [[CapeGameTreatObject node] cons_pt:pt];
}
-(id)cons_pt:(CGPoint)pt {
	[self setTexture:[Resource get_tex:TEX_ITEM_SS]];
	[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"treat"]];
	[self csf_setScale:0.7];
	[self setPosition:pt];
	active = YES;
	follow = NO;
	return self;
}
-(void)on_hit:(CapeGameEngineLayer *)g {
	[AudioManager playsfx:SFX_POWERUP];
	[GEventDispatcher immediate_event:[GEvent cons_type:GEventType_GET_TREAT]];
	[[g get_ui] do_treat_collect_anim:g.player.position];
}
@end

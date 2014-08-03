#import "DogCape.h"
#import "AudioManager.h"

@implementation DogCape {
	NSString *_map;
}

+(DogCape*)cons_x:(float)x y:(float)y {
	return [[DogCape node] cons_pt:ccp(x,y) map:NULL];
}

+(DogCape*)cons_x:(float)x y:(float)y map:(NSString *)map {
	return [[DogCape node] cons_pt:ccp(x,y) map:map];
}

-(id)cons_pt:(CGPoint)pt map:(NSString*)map {
	[self setPosition:pt];
	[self setTexture:[Resource get_tex:TEX_ITEM_SS]];
	[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"pickup_dogcape"]];
	active = YES;
	[self csf_setScale:1.5];
	_map = map;
	
	return self;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-15 y1:[self position].y-15 wid:30 hei:30];
}

-(void)hit {
	[AudioManager playsfx:SFX_POWERUP];
	if (_map) {
		[GEventDispatcher push_event:[[GEvent cons_type:GEventType_BEGIN_CAPE_GAME] add_key:@"map" value:_map]];
	} else {
		[GEventDispatcher push_event:[GEvent cons_type:GEventType_BEGIN_CAPE_GAME]];
	}
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

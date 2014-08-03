#import "Shopkeeper.h"
#import "MenuCommon.h"

@implementation Shopkeeper

+(Shopkeeper*)cons_pt:(CGPoint)pt {
    Shopkeeper *s = [Shopkeeper node];
    [s setPosition:pt];
    return s;
}

-(id)init {
    self = [super init];
    NSMutableArray *a = [NSMutableArray array];
    for(int i = 0; i < 15; i++) [a addObject:@"nmenu_shopkeeper"];
    [a addObject:@"nmenu_shopkeeper_blink"];
    [self runAction:[self cons_anim:a speed:0.25]];
    return self;
}

-(CCAction*)cons_anim:(NSArray*)a speed:(float)speed {
	CCTexture2D *texture = [Resource get_tex:TEX_NMENU_ITEMS];
	NSMutableArray *animFrames = [NSMutableArray array];
    for (NSString* k in a) [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:k]]];
    return [Common make_anim_frames:animFrames speed:speed];
}

-(void)dealloc {
	[self stopAllActions];
}
@end

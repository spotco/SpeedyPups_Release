#import "Flowers.h"
#import "Resource.h"
#import "Common.h"
#import "FileCache.h"

@implementation Flowers

+(Flowers*)cons_pt:(CGPoint)pt {
    Flowers *f = [Flowers node];
    [f setPosition:pt];
    return f;
}

-(id)init {
    self = [super init];
    [self runAction:[self cons_anim:
                     [NSArray arrayWithObjects:@"nmenu_flower_3",@"nmenu_flower_2",@"nmenu_flower_1",@"nmenu_flower_2", nil]
                              speed:0.5]];
    
    
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

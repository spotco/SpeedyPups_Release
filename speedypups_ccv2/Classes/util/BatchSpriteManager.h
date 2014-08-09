#import "CCNode.h"
@class CCSprite;

@protocol BatchableSprite <NSObject>
@required
-(BOOL)is_batched_sprite;
-(NSString*)get_batch_sprite_tex_key;
-(int)get_render_ord;
@end

@interface BatchSpriteManager : CCNode
+(BatchSpriteManager*)cons;
@end
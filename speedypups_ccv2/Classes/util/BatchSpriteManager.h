#import "CCNode.h"
@class CCSprite;

@protocol BatchableSprite <NSObject>
@required
-(BOOL)is_batched_sprite;
-(NSString*)get_batch_sprite_tex_key;
-(int)get_render_ord;
@end

@interface BatchSpriteManager : NSObject
+(BatchSpriteManager*)cons:(CCNode*)sur;

-(void)addChild:(CCNode *)node;
-(void)addChild:(CCNode *)node z:(NSInteger)z;
-(void)removeChild:(CCNode *)child;
-(void)removeChild:(CCNode *)node cleanup:(BOOL)cleanup;

-(void)setColor:(ccColor3B)color;
@end
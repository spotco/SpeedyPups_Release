#import "BatchSpriteManager.h"
#import "cocos2d.h"
#import "Resource.h"
#import "GameEngineLayer.h"

@implementation BatchSpriteManager {
	NSMutableDictionary *tex_key_to_batch_node;
	CCNode __unsafe_unretained *sur;
}

static NSMutableDictionary *_cached_sprite_frames;

#define cache_sprite_frame(tex_ss) [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:[NSString stringWithFormat:@"%@.plist",tex_ss] texture:[Resource get_tex:tex_ss]];
+(void)cache_sprite_frames {
	cache_sprite_frame(TEX_ITEM_SS);
	cache_sprite_frame(TEX_GROUND_DETAILS);
	cache_sprite_frame(TEX_GROUND_DETAILS_WORLD2);
	cache_sprite_frame(TEX_BG3_GROUND_DETAIL_SS);
	cache_sprite_frame(TEX_PARTICLES);
}

+(BatchSpriteManager*)cons:(CCNode *)sur {
	return [[[BatchSpriteManager alloc] init] cons_sur:sur];
}

-(id)cons_sur:(CCNode*)_sur {
	tex_key_to_batch_node = [NSMutableDictionary dictionary];
	sur = _sur;
	return self;
}

-(NSString*)key_from_batchable:(id<BatchableSprite>)obj {
	return [NSString stringWithFormat:@"%@_%d",[obj get_batch_sprite_tex_key],[obj get_render_ord]];
}

-(void)addChild:(CCNode *)node { [self addChild:node z:0]; }
-(void)addChild:(CCNode *)node z:(NSInteger)z {
	if ([node conformsToProtocol:@protocol(BatchableSprite)]) {
		id<BatchableSprite> tar = (id<BatchableSprite>)node;
		NSString *key = [self key_from_batchable:tar];
		if (![tex_key_to_batch_node objectForKey:key]) [self make_batchnode_texkey:[tar get_batch_sprite_tex_key] ord:[tar get_render_ord] key:key];
		CCSpriteBatchNode *parent = [tex_key_to_batch_node objectForKey:key];
		[parent addChild:(CCSprite*)tar];
		
	} else {
		[sur addChild:node z:z];
	}
}

-(void)make_batchnode_texkey:(NSString*)texkey ord:(int)ord key:(NSString*)key {
	CCSpriteBatchNode *neu = [CCSpriteBatchNode batchNodeWithTexture:[Resource get_tex:texkey]];
	[tex_key_to_batch_node setObject:neu forKey:key];
	[sur addChild:neu z:ord];
}

-(void)removeChild:(CCNode *)child { [self removeChild:child cleanup:NO]; }
-(void)removeChild:(CCNode *)node cleanup:(BOOL)cleanup {
	if ([node conformsToProtocol:@protocol(BatchableSprite)]) {
		id<BatchableSprite> tar = (id<BatchableSprite>)node;
		NSString *key = [self key_from_batchable:tar];
		if (![tex_key_to_batch_node objectForKey:key]) NSLog(@"ERROR REMOVING FROM NONEXISTANT BATCH SPRITE");
		CCSpriteBatchNode *parent = [tex_key_to_batch_node objectForKey:key];
		[parent removeChild:(CCSprite*)tar cleanup:YES];
		
	} else {
		[sur removeChild:node cleanup:cleanup];
	}
}

-(void)setColor:(ccColor3B)color {
	for (CCNode* i in [sur children]) {
		if ([i respondsToSelector:@selector(setColor:)]) {
			[(CCSprite*)i setColor:color];
		}
	}
	for (NSString *key in [tex_key_to_batch_node keyEnumerator]) {
		CCSpriteBatchNode *batchnode = tex_key_to_batch_node[key];
		for (CCSprite *i in [batchnode children]) {
			[i setColor:color];
		}
	}
}

@end

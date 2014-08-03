#import "ExtrasArtPopup.h"
#import "Resource.h"
#import "MenuCommon.h"

@implementation ExtrasArtPopup {
	CCTexture2D *tex;
	CCSprite *img;
}
+(ExtrasArtPopup*)cons_key:(NSString*)key {
	return [[ExtrasArtPopup node] cons_key:key];
}

-(id)cons_key:(NSString*)key {
	tex = [[CCTextureCache sharedTextureCache] addImage:key];
	[self setPosition:CGPointZero];
	
	[self addChild:[CCLayerColor layerWithColor:ccc4(0, 0, 0, 255)]];
	
	img = [CCSprite spriteWithTexture:tex];
	[img setAnchorPoint:ccp(0.5,0.5)];
	[img setScale:CC_CONTENT_SCALE_FACTOR()];
	[img setPosition:[Common screen_pctwid:0.5 pcthei:0.5]];
	[self addChild:img];
	[self setScale:1];
	
	return self;
}

-(void)add_close_button:(CallBack *)on_close {
	CCSprite *p_a = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BLANK]];
	CCSprite *p_b = [CCSprite spriteWithTexture:[Resource get_tex:TEX_BLANK]];
	[p_a setTextureRect:CGRectMake(0, 0, [Common SCREEN].width, [Common SCREEN].height)];
	[p_b setTextureRect:CGRectMake(0, 0, [Common SCREEN].width, [Common SCREEN].height)];
	[p_a setOpacity:0];
	[p_b setOpacity:20];
	
    CCMenuItemSprite *closebutton = [CCMenuItemSprite itemFromNormalSprite:p_a
                                                  selectedSprite:p_b
                                                          target:on_close.target
                                                        selector:on_close.selector];
	
	[closebutton setAnchorPoint:ccp(1,1)];
    [closebutton setPosition:[Common screen_pctwid:1 pcthei:1]];
	CCMenu *invmh = [CCMenu menuWithItems:closebutton, nil];
	[invmh setPosition:CGPointZero];
    [self addChild:invmh];
}

-(void)dealloc {
	[self removeAllChildrenWithCleanup:YES];
	[img setTexture:[Resource get_tex:TEX_BLANK]];
	[[CCTextureCache sharedTextureCache] removeTexture:tex];
	tex = NULL;
}
@end

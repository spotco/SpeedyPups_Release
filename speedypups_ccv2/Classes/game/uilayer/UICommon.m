#import "UICommon.h"
#import "Common.h"
#import "GameEngineLayer.h"

@implementation UICommon
+(NSString*)parse_gameengine_time:(int)t {
    t*=20;
    return strf("%i:%i%i",t/60000,(t/10000)%6,(t/1000)%10);
}
+(CGPoint)player_approx_position:(GameEngineLayer*)game_engine_layer {
	CameraZoom state = [game_engine_layer get_layer_camera];
	float rtv_x = (state.x + [Common SCREEN].width/2);
	float rtv_y = (state.y + [Common SCREEN].height/2);
	return ccp(rtv_x,rtv_y);
}
+(CGPoint)game_to_screen_pos:(CGPoint)pos g:(GameEngineLayer*)g {
	return [g convertToWorldSpace:pos];
}

+(void)set_zoom_pos_align:(CCSprite*)normal zoomed:(CCSprite*)zoomed scale:(float)scale {
    zoomed.scale = scale;
    zoomed.position = ccp((-[zoomed contentSize].width * zoomed.scale + [zoomed contentSize].width)/2
                          ,(-[zoomed contentSize].height * zoomed.scale + [zoomed contentSize].height)/2);
}
+(CCLabelTTF*)cons_label_pos:(CGPoint)pos color:(ccColor3B)color fontsize:(int)fontsize{
    CCLabelTTF *l = [CCLabelTTF labelWithString:@"" fontName:@"Carton Six" fontSize:fontsize];
    [l setColor:color];
    [l setPosition:pos];
    [l setString:@"*"];
    return l;
}
+(CCMenuItemLabel*)label_cons_menuitem:(CCLabelTTF*)l leftalign:(BOOL)leftalign {
    CCMenuItemLabel *m = [CCMenuItemLabel itemWithLabel:l];
    if (leftalign) [m setAnchorPoint:ccp(0,m.anchorPoint.y)];
    return m;
}
+(CCMenuItem*)cons_menuitem_tex:(CCTexture2D*)tex pos:(CGPoint)pos {
    CCMenuItem* i = [CCMenuItemSprite itemFromNormalSprite:[CCSprite spriteWithTexture:tex] selectedSprite:[CCSprite spriteWithTexture:tex]];
    [i setPosition:pos];
    return i;
}
+(void)button:(CCNode *)btn add_desctext:(NSString *)txt color:(ccColor3B)color fntsz:(int)fntsz {
	[btn addChild:[[Common cons_label_pos:[Common pct_of_obj:btn pctx:0.5 pcty:-0.1]
										color:color
									 fontsize:fntsz
										  str:txt] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
}
@end

@implementation MenuCurtains

@synthesize left_curtain_tpos, right_curtain_tpos, bg_curtain_tpos;
@synthesize left_curtain, right_curtain;
@synthesize bg_curtain;

+(MenuCurtains*)cons {
	return [MenuCurtains node];
}

-(id)init {
	self = [super init];
	
	left_curtain = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
											  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"curtain_left"]];
	[left_curtain setAnchorPoint:ccp(0.5,0)];
	right_curtain = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
											   rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"curtain_left"]];
	[right_curtain setAnchorPoint:ccp(0.5,0)];
	bg_curtain = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
										rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"curtain_bg"]];
	[right_curtain csf_setScaleX:-1];
	[bg_curtain setAnchorPoint:ccp(0.5,0)];
	[bg_curtain setScaleX:[Common SCREEN].width/[bg_curtain boundingBox].size.width];
	[bg_curtain setScaleY:[Common SCREEN].height/[bg_curtain boundingBox].size.height];
	[self addChild:bg_curtain];
	[self addChild:left_curtain];
	[self addChild:right_curtain];
	[self set_curtain_animstart_positions];
	
	return self;
}

-(void)set_curtain_animstart_positions {
	[left_curtain setPosition:ccp(-[left_curtain boundingBox].size.width,[Common SCREEN].height/2.0)];
    [right_curtain setPosition:ccp([Common SCREEN].width + [left_curtain boundingBox].size.width,[Common SCREEN].height/2.0)];
	[bg_curtain setPosition:ccp([Common SCREEN].width/2.0,[Common SCREEN].height)];
	
	left_curtain_tpos = ccp([left_curtain boundingBox].size.width/2.0,[Common SCREEN].height/2.0);
	right_curtain_tpos = ccp([Common SCREEN].width-[right_curtain boundingBox].size.width/2.0,[Common SCREEN].height/2.0);
	bg_curtain_tpos = ccp([Common SCREEN].width/2.0,[Common SCREEN].height-[bg_curtain boundingBox].size.height*0.15);
}

-(void)update {
	[left_curtain setPosition:ccp(left_curtain.position.x + (left_curtain_tpos.x - left_curtain.position.x)/4.0,[Common SCREEN].height-left_curtain.boundingBox.size.height)];
	[right_curtain setPosition:ccp(right_curtain.position.x + (right_curtain_tpos.x - right_curtain.position.x)/4.0,[Common SCREEN].height-left_curtain.boundingBox.size.height)];
	[bg_curtain setPosition:ccp(
		bg_curtain.position.x + (bg_curtain_tpos.x - bg_curtain.position.x)/4.0,
		bg_curtain.position.y + (bg_curtain_tpos.y - bg_curtain.position.y)/4.0
	)];
}

@end

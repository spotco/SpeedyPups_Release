#import "GameOverUI.h"
#import "PauseUI.h"
#import "Common.h"
#import "Resource.h"
#import "MenuCommon.h"
#import "UserInventory.h"
#import "GameEngineLayer.h"
#import "UICommon.h"
#import "UILayer.h"
#import "GameEngineLayer.h" 

@implementation GameOverUI

+(GameOverUI*)cons {
    return [GameOverUI node];
}


-(id)init {
    self = [super init];
    
    ccColor4B c = {50,50,50,220};
    CGSize s = [[UIScreen mainScreen] bounds].size;
    CCNode *gameover_ui = [CCLayerColor layerWithColor:c width:s.height height:s.width];
    gameover_ui.anchorPoint = ccp(0,0);
    [gameover_ui setPosition:ccp(0,0)];
	
	
	MenuCurtains *curtains = [MenuCurtains cons];
	[curtains.left_curtain setAnchorPoint:ccp(0.5,0.5)];
	[curtains.right_curtain setAnchorPoint:ccp(0.5,0.5)];
	[curtains.left_curtain setPosition:ccp([curtains.left_curtain boundingBox].size.width/2.0,[Common SCREEN].height/2.0)];
	[curtains.right_curtain setPosition:ccp([Common SCREEN].width-[curtains.right_curtain boundingBox].size.width/2.0,[Common SCREEN].height/2.0)];
	[curtains.bg_curtain setPosition:ccp([Common SCREEN].width/2.0,0)];
	[gameover_ui addChild:curtains];
    
    [gameover_ui addChild:[[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
                                                  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"gameover"]]
                            pos:[Common screen_pctwid:0.5 pcthei:0.8]]];
    
    CCMenuItem *backbutton = [MenuCommon item_from:TEX_UI_INGAMEUI_SS rect:@"homebutton" tar:self sel:@selector(exit_to_menu)
                                               pos:[Common screen_pctwid:0.3 pcthei:0.135]];
    
    CCMenuItem *retrybutton = [MenuCommon item_from:TEX_UI_INGAMEUI_SS rect:@"retrybutton" tar:self sel:@selector(retry)
                                               pos:[Common screen_pctwid:0.7 pcthei:0.135]];
    
    CCMenu *m = [CCMenu menuWithItems:backbutton,retrybutton, nil];
    [m setPosition:CGPointZero];
    [gameover_ui addChild:m];
    
	[UICommon button:backbutton add_desctext:@"to menu" color:ccc3(255,255,255) fntsz:13];
	[UICommon button:retrybutton add_desctext:@"retry" color:ccc3(255,255,255) fntsz:13];
    
    [self addChild:gameover_ui];
	
	
	info_disp_pane = [[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
													  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"gameover_info_disp_pane"]]
								pos:[Common screen_pctwid:0.5 pcthei:0.43]];
	[info_disp_pane addChild:[[Common cons_label_pos:[Common pct_of_obj:info_disp_pane pctx:0.5 pcty:0.9]
											  color:ccc3(0,0,0)
										   fontsize:19
												str:@"stats"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	ClippingNode *clipper = [ClippingNode node];
	//[clipper setClippingRegion:CGRectMake(0, 0, 568, 320)];
	
	CGPoint tarpt = [Common screen_pctwid:0.5 pcthei:0.43];
	tarpt.x -= [info_disp_pane boundingBox].size.width/2;
	tarpt.y -= [info_disp_pane boundingBox].size.height/2;
	tarpt.x += 10;
	tarpt.y += 10;
	CGPoint tarsize = ccp([info_disp_pane boundingBox].size.width-20,[info_disp_pane boundingBox].size.height*0.69);
	[clipper setClippingRegion:CGRectMake(tarpt.x, tarpt.y, tarsize.x, tarsize.y)];
	
	
	[info_disp_pane addChild:[MenuCommon cons_descaler_for:clipper pos:CGPointZero]];
	[gameover_ui addChild:info_disp_pane];
	
	CGPoint topleft = ccp(12,tarsize.y+10);
	clippedholder = [CCSprite node];
	[clipper addChild:clippedholder];
	
	stat_labels = @{
		NSV(GEStat_POINTS):[self cons_label_name:@"points" posmlt:0 parent:clippedholder topleft:topleft size:tarsize],
		NSV(GEStat_TIME):[self cons_label_name:@"time" posmlt:1 parent:clippedholder topleft:topleft size:tarsize],
		NSV(GEStat_BONES_COLLECTED):[self cons_label_name:@"bones collected" posmlt:2 parent:clippedholder topleft:topleft size:tarsize],
		NSV(GEStat_DEATHS):[self cons_label_name:@"deaths" posmlt:3 parent:clippedholder topleft:topleft size:tarsize],
		NSV(GEStat_DISTANCE):[self cons_label_name:@"distance traveled" posmlt:4 parent:clippedholder topleft:topleft size:tarsize],
		NSV(GEStat_SECTIONS):[self cons_label_name:@"sections passed" posmlt:5 parent:clippedholder topleft:topleft size:tarsize],
		NSV(GEStat_JUMPED):[self cons_label_name:@"times jumped" posmlt:6 parent:clippedholder topleft:topleft size:tarsize],
		NSV(GEStat_DASHED):[self cons_label_name:@"times dashed" posmlt:7 parent:clippedholder topleft:topleft size:tarsize],
		NSV(GEStat_DROWNED):[self cons_label_name:@"deaths by drowning" posmlt:8 parent:clippedholder topleft:topleft size:tarsize],
		NSV(GEStat_SPIKES):[self cons_label_name:@"deaths by spikes" posmlt:9 parent:clippedholder topleft:topleft size:tarsize],
		NSV(GEStat_FALLING):[self cons_label_name:@"deaths by falling" posmlt:10 parent:clippedholder topleft:topleft size:tarsize],
		NSV(GEStat_ROBOT):[self cons_label_name:@"deaths by robot" posmlt:11 parent:clippedholder topleft:topleft size:tarsize]
	};
	
	is_info_disp_pane_scroll = NO;
	clippedholder_y_min = 0;
	
	can_scroll_down = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"scroll_arrow"]];
	[can_scroll_down setScaleX:0.3];
	[can_scroll_down setScaleY:-1];
	can_scroll_up = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"scroll_arrow"]];
	[can_scroll_up setScaleX:0.3];
	[can_scroll_down setPosition:[Common pct_of_obj:info_disp_pane pctx:0.95 pcty:0.07]];
	[can_scroll_up setPosition:[Common pct_of_obj:info_disp_pane pctx:0.95 pcty:0.745]];
	[info_disp_pane addChild:can_scroll_down];
	[info_disp_pane addChild:can_scroll_up];
	
	[self schedule:@selector(update)];
	
    return self;
}

-(CCLabelTTF*)cons_label_name:(NSString*)name posmlt:(int)posmlt parent:(CCNode*)parent topleft:(CGPoint)topleft size:(CGPoint)size {
	CCLabelTTF *namelabel = [Common cons_label_pos:CGPointZero color:ccc3(0, 0, 0) fontsize:16 str:name];
	[namelabel setAnchorPoint:ccp(0,1)];
	[namelabel setPosition:ccp(topleft.x,topleft.y - posmlt * [namelabel boundingBox].size.height)];
	[parent addChild:namelabel];
	clippedholder_y_max = MAX(clippedholder_y_max,namelabel.position.y + [namelabel boundingBox].size.height + 20);
	
	CCLabelTTF *valuelabel = [Common cons_label_pos:CGPointZero color:ccc3(210,30,30) fontsize:16 str:@"top lel"];
	[valuelabel setPosition:ccp(topleft.x+size.x-10,namelabel.position.y)];
	[valuelabel setAnchorPoint:ccp(1,1)];
	[parent addChild:valuelabel];
	
	return valuelabel;
}

-(void)set_stats:(GameEngineLayer *)g {
	for (NSValue *key in g.get_stats.get_all_stats) {
		CCLabelTTF *labbel = stat_labels[key];
		if (labbel != NULL) {
			[labbel setString:[g.get_stats get_disp_str_for_stat:(GEStat)key.pointerValue g:g]];
		}
	}
}

-(void)touch_begin:(CGPoint)pt {
	if (![self visible]) return;
	CGRect bbox;
	bbox.origin = ccp(info_disp_pane.position.x-info_disp_pane.boundingBox.size.width/2.0,info_disp_pane.position.y);
	bbox.size = info_disp_pane.boundingBox.size;
	
	if (CGRectContainsPoint(bbox, pt)) {
		is_info_disp_pane_scroll = YES;
		last_info_disp_pane_scroll_pt = pt;
		disp_pane_scroll_move_ct = 0;
	} else {
		is_info_disp_pane_scroll = NO;
	}
}

-(void)touch_move:(CGPoint)pt {
	if (![self visible]) return;
	if (!is_info_disp_pane_scroll) return;
	CGPoint ydelta = ccp(0,last_info_disp_pane_scroll_pt.y-pt.y);
	last_info_disp_pane_scroll_pt = pt;
	
	float sign = [Common sig:ydelta.y];
	float av = 10.0*MIN(ABS(ydelta.y),30)/30.0;
	av /= MAX(1,8.0-disp_pane_scroll_move_ct);
	vy += sign * av;
	disp_pane_scroll_move_ct++;
}

-(void)touch_end:(CGPoint)pt {
	if (![self visible]) return;
	is_info_disp_pane_scroll = NO;
}

-(void)update {
	CGPoint neupos = CGPointAdd(ccp(0,vy), clippedholder.position);
	neupos.y = clampf(neupos.y, clippedholder_y_min, clippedholder_y_max);
	[clippedholder setPosition:neupos];
	vy *= 0.8;
	[can_scroll_up setVisible:neupos.y != clippedholder_y_min];
	[can_scroll_down setVisible:neupos.y != clippedholder_y_max];
	
}

-(void)retry {
    [(UILayer*)[self parent] retry];
}

-(void)exit_to_menu {
    [(UILayer*)[self parent] exit_to_menu];
}

-(void)setVisible:(BOOL)visible {
	[super setVisible:visible];
	if (visible) {
		[AudioManager playsfx:SFX_WHIMPER];
	}
	
}

@end

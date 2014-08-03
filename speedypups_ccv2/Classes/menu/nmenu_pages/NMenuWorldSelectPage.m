#import "NMenuWorldSelectPage.h"
#import "MenuCommon.h"
#import "GameMain.h"
#import "FreeRunStartAtManager.h"

@interface MapIconTouchButton : TouchButton {
	CGRect clipping_area;
	CCLabelTTF *disp_text;
}
@property (readwrite,assign) FreeRunStartAt starting_loc;
+(MapIconTouchButton*)cons_loc:(FreeRunStartAt)loc pos:(CGPoint)pos clip:(CGRect)clip cb:(CallBack*)tcb;
-(void)update;
@end

@implementation MapIconTouchButton
@synthesize starting_loc;
+(MapIconTouchButton*)cons_loc:(FreeRunStartAt)loc pos:(CGPoint)pos clip:(CGRect)clip cb:(CallBack *)tcb {
	return [[MapIconTouchButton node] cons_loc:loc pos:pos clip:clip cb:tcb];
}

-(id)cons_loc:(FreeRunStartAt)loc pos:(CGPoint)pos clip:(CGRect)clip cb:(CallBack*)tcb {
	[self setPosition:pos];
	starting_loc = loc;
	clipping_area = clip;
	self.cb = tcb;
	
	disp_text = [[Common cons_label_pos:ccp([FreeRunStartAtManager get_icon_for_loc:loc].rect.size.width/2.0,-7)
								 color:ccc3(0,0,0)
							  fontsize:13
								   str:[FreeRunStartAtManager name_for_loc:loc]] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[self addChild:disp_text];
	[self set_icon_and_text];
	
	return self;
}

-(void)set_icon_and_text {
	TexRect *tr = [FreeRunStartAtManager get_icon_for_loc:starting_loc];
	[self setTexture:tr.tex];
	if ([FreeRunStartAtManager get_can_start_at:starting_loc]) {
		[self setTextureRect:tr.rect];
		[disp_text setColor:ccc3(0,0,0)];
		[disp_text setString:[FreeRunStartAtManager name_for_loc:starting_loc]];
		
	} else {
		[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_FREERUNSTARTICONS idname:@"icon_question"]];
		[disp_text setColor:ccc3(80,80,80)];
		[disp_text setString:@"Locked"];
		
	}
}

-(void)update {
	[self csf_setScale:(1-self.csf_scale)/5.0+self.csf_scale];
}

-(void)touch_begin:(CGPoint)pt {
	if (![FreeRunStartAtManager get_can_start_at:starting_loc]) return;
	CGPoint scrn_pt = pt;
	pt = [self convertToNodeSpace:pt];
	CGRect hitrect = [self hit_rect_local];
	if (CGRectContainsPoint(hitrect, pt)) {
		if (!CGRectContainsPoint(clipping_area, scrn_pt)) {
			return;
		}
		[self csf_setScale:1.4];
		[self.cb.target performSelector:self.cb.selector withObject:self];
	}
}

-(CGRect)hit_rect_local {
	CGRect hr = [super hit_rect_local];
	hr.origin.x -= 10;
	hr.origin.y -= 10;
	hr.size.width += 20;
	hr.size.height += 20;

	return hr;
}

@end

@implementation NMenuWorldSelectPage

+(NMenuWorldSelectPage*)cons {
    return [NMenuWorldSelectPage node];
}

-(id)init {
    self = [super init];
	
	touches = [NSMutableArray array];
    
    [GEventDispatcher add_listener:self];
    [self addChild:[Common cons_label_pos:[Common screen_pctwid:0.5 pcthei:0.85] color:ccc3(0,0,0) fontsize:18 str:@"World Start"]];

	ClippingNode *clipper = [ClippingNode node];
	[clipper setClippingRegion:CGRectMake(
		[Common SCREEN].width*0.2,
		[Common SCREEN].height*0.4,
		[Common SCREEN].width * 0.6,
		[Common SCREEN].height * 0.45
	)];
	[self addChild:clipper];
	
	clipper_anchor = [CCSprite node];
	CCSprite *zero_anchor = [[CCSprite node] pos:ccp([Common SCREEN].width*0.175,[Common SCREEN].height*0.44)];
	[zero_anchor addChild:clipper_anchor];
	[clipper addChild:zero_anchor];
	
	[clipper_anchor addChild:[[[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_NMENU_LEVELSELOBJ]
													rect:[FileCache get_cgrect_from_plist:TEX_NMENU_LEVELSELOBJ idname:@"world_select_map"]]
							  anchor_pt:ccp(0,0)] pos:ccp(0,-12.5)]];
	
	FreeRunStartAt loc[] = {FreeRunStartAt_TUTORIAL,FreeRunStartAt_WORLD1,FreeRunStartAt_LAB1,FreeRunStartAt_WORLD2,FreeRunStartAt_LAB2,FreeRunStartAt_WORLD3,FreeRunStartAt_LAB3};
	CGPoint locpos[] = {ccp(77,47), ccp(175,85), ccp(275,49), ccp(377,28), ccp(487,40), ccp(597,75), ccp(702,67)};
	CGPoint selector_icon_position = ccp(50,70);
	for(int i = 0; i < 7; i++) {
		MapIconTouchButton *b = [MapIconTouchButton cons_loc:loc[i]
														 pos:locpos[i]
														clip:clipper.clippingRegion
														  cb:[Common cons_callback:self sel:@selector(mapicontouch:)]];
		[clipper_anchor addChild:b];
		[touches addObject:b];
		clippedholder_x_min = -locpos[i].x + [Common SCREEN].width * 0.475;
		
		if (loc[i] == [FreeRunStartAtManager get_starting_loc]) {
			selector_icon_position = CGPointAdd(b.position, ccp(0,20));
			[b setOpacity:255];
		} else {
			[b setOpacity:150];
		}
	}
	
	selector_icon = [CSF_CCSprite node];
	[selector_icon runAction:[Common cons_anim:@[@"dog_selector_0",@"dog_selector_1"] speed:0.2 tex_key:TEX_NMENU_ITEMS]];
	[selector_icon csf_setScale:0.6];
	[selector_icon setAnchorPoint:ccp(0.44,0.5)];
	[selector_icon setPosition:selector_icon_position];
	selector_icon_target_pos = selector_icon.position;
	[clipper_anchor addChild:selector_icon];
	
	CGPoint neupos = ccp(-(selector_icon_position.x-clipper.clippingRegion.size.width/2.0),clipper_anchor.position.y);
	neupos.x = clampf(neupos.x, clippedholder_x_min, clippedholder_x_max);
	[clipper_anchor setPosition:neupos];
	
	scroll_right_arrow = [HoldTouchButton cons_pt:[Common screen_pctwid:0.83 pcthei:0.615]
											 tex:[Resource get_tex:TEX_NMENU_ITEMS]
										 texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"settingspage_scrollright"]];
	[scroll_right_arrow setScaleX:1.5];
	[self addChild:scroll_right_arrow];
	[touches addObject:scroll_right_arrow];
	
	scroll_left_arrow = [HoldTouchButton cons_pt:[Common screen_pctwid:0.17 pcthei:0.615]
											 tex:[Resource get_tex:TEX_NMENU_ITEMS]
										 texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"settingspage_scrollright"]];
	[scroll_left_arrow setScaleX:-1.5];
	[self addChild:scroll_left_arrow];
	[touches addObject:scroll_left_arrow];
	
	
	
    [self addChild:[MenuCommon cons_common_nav_menu]];
	
	clippedholder_x_max = 0;
	
    return self;
}

-(void)mapicontouch:(MapIconTouchButton*)button {
	if ([FreeRunStartAtManager get_can_start_at:button.starting_loc]) {
		[FreeRunStartAtManager set_starting_loc:button.starting_loc];
		selector_icon_target_pos = CGPointAdd(button.position, ccp(0,20));
		
		for (TouchButton *b in touches) if ([b class] == [MapIconTouchButton class]) [b setOpacity:150];
		[button setOpacity:255];
		
		[Player character_bark];
		[AudioManager playsfx:SFX_MENU_UP];
		
	} else {
		NSLog(@"mapicontouch ERROR");
	}
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_MENU_INVENTORY) {
    } else if (e.type == GEVentType_MENU_CLOSE_INVENTORY) {
    } else if (e.type == GEventType_MENU_TICK && self.visible) {
		[self update];
	}
}

-(void)setVisible:(BOOL)visible {
	if (visible) {
		for (MapIconTouchButton *b in touches) {
			if ([b respondsToSelector:@selector(set_icon_and_text)]) {
				[b set_icon_and_text];
			}
		}
	}
	[super setVisible:visible];
}

-(void)update {
	if (![self visible]) return;
	CGPoint neupos;
	if (scroll_left_arrow.pressed) {
		neupos = CGPointAdd(ccp(7.5,0), clipper_anchor.position);
	} else if (scroll_right_arrow.pressed) {
		neupos = CGPointAdd(ccp(-7.5,0), clipper_anchor.position);
	} else {
		neupos = CGPointAdd(ccp(vx,0), clipper_anchor.position);
	}
	
	neupos.x = clampf(neupos.x, clippedholder_x_min, clippedholder_x_max);
	[clipper_anchor setPosition:neupos];
	vx *= 0.8;
	[scroll_right_arrow setVisible:neupos.x > clippedholder_x_min];
	[scroll_left_arrow setVisible:neupos.x < clippedholder_x_max];
	
	selector_icon.position = ccp(
		(selector_icon_target_pos.x-selector_icon.position.x)/5.0+selector_icon.position.x,
		(selector_icon_target_pos.y-selector_icon.position.y)/5.0+selector_icon.position.y
	);
	
	for (MapIconTouchButton *btn in touches) {
		if ([btn respondsToSelector:@selector(update)]) {
			[btn update];
		}
	}
	

	
}

-(void)touch_begin:(CGPoint)pt {	
	is_scroll = YES;
	last_scroll_pt = pt;
	scroll_move_ct = 0;
	for (TouchButton *b in touches) {
		if ([[b class] isSubclassOfClass:[HoldTouchButton class]]) [b touch_begin:pt];
	}
}

-(void)touch_move:(CGPoint)pt {
	if (![self visible]) return;
	if (!is_scroll) return;
	CGPoint ydelta = ccp(-last_scroll_pt.x+pt.x,0);
	last_scroll_pt = pt;
	
	float sign = [Common sig:ydelta.x];
	float av = 10.0*MIN(ABS(ydelta.x),30)/30.0;
	av /= MAX(1,8.0-scroll_move_ct);
	vx += sign * av;
	scroll_move_ct++;
	
	for (TouchButton *b in touches) {
		if ([[b class] isSubclassOfClass:[HoldTouchButton class]]) [b touch_move:pt];
	}
}

-(void)touch_end:(CGPoint)pt {
	if (![self visible]) return;
	if (scroll_move_ct < 5) {
		for (int i = (int)touches.count-1; i>=0; i--) {
			TouchButton *b = touches[i];
			[b touch_begin:pt];
		}
	}
	is_scroll = NO;
	
	for (TouchButton *b in touches) {
		if ([[b class] isSubclassOfClass:[HoldTouchButton class]]) [b touch_end:pt];
	}
}

-(void)dealloc {
	[touches removeAllObjects];
	[self removeAllChildrenWithCleanup:YES];
}


@end


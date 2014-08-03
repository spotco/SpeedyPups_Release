#import "SpinButton.h"
#import "UICommon.h"

typedef enum SpinButtonMode {
	SpinButtonMode_OK,
	SpinButtonMode_LOCKED_TIME,
	SpinButtonMode_LOCKED_BONES
} SpinButtonMode;

@implementation SpinButton {
	SpinButtonMode mode;
	BOOL pressed;
	
	CCLabelTTF *time_disp;
	CCLabelTTF *cost_disp;
	CCSprite *locked_icon;
}

+(SpinButton*)cons_pt:(CGPoint)pos cb:(CallBack*)cb {
	return [[SpinButton node] cons_pt:pos cb:cb];
}

-(id)cons_pt:(CGPoint)pos cb:(CallBack*)cb {
	[super cons_pt:pos
			   tex:[Resource get_tex:TEX_UI_INGAMEUI_SS]
		   texrect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"spinbutton"]
				cb:cb];
	
	locked_icon = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ITEM_SS]
										 rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"item_clock"]];
	//[locked_icon setScale:0.58];
	[locked_icon setPosition:[Common pct_of_obj:self pctx:0.295 pcty:0.58]];
	[self addChild:locked_icon];
	
	
	time_disp = [[Common cons_label_pos:[Common pct_of_obj:self pctx:0.6 pcty:0.575]
								 color:ccc3(200,30,30)
							  fontsize:17
								   str:@""] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[self addChild:time_disp];
	
	cost_disp = [[Common cons_label_pos:CGPointZero
								 color:ccc3(200,30,30)
							  fontsize:20
								   str:@""] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[self addChild:cost_disp];
	
	[self setScale:0.8];
	
	mode = SpinButtonMode_LOCKED_TIME;
	pressed = NO;
	[self update_image];
	return self;
}

-(void)lock_time:(long)time {
	mode = SpinButtonMode_LOCKED_TIME;
	[time_disp set_label:[MenuCommon secs_to_prettystr:time]];
	[self update_image];
}

-(void)lock_time_string:(NSString*)msg {
	mode = SpinButtonMode_LOCKED_TIME;
	[time_disp set_label:msg];
	[self update_image];
}

-(void)lock_bones:(int)cost {
	mode = SpinButtonMode_LOCKED_BONES;
	[time_disp set_label:strf("%d",cost)];
	[self update_image];
}

-(void)unlock_cost:(int)cost {
	mode = SpinButtonMode_OK;
	[cost_disp set_label:strf("%d",cost)];
	[self update_image];
}

-(void)start_spin {
	[Common run_callback:self.cb];
	mode = SpinButtonMode_LOCKED_TIME;
	[self update_image];
}

-(void)update_image {
	if (mode == SpinButtonMode_LOCKED_BONES) {
		[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"spinbutton_locked"]];
		[time_disp setVisible:YES];
		[cost_disp setVisible:NO];
		[locked_icon setVisible:YES];
		[locked_icon setTextureRect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"goldenbone"]];
		[locked_icon setScale:1.05];
		
	} else if (mode == SpinButtonMode_LOCKED_TIME) {
		[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"spinbutton_locked"]];
		[time_disp setVisible:YES];
		[cost_disp setVisible:NO];
		[locked_icon setVisible:YES];
		[locked_icon setTextureRect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"item_clock"]];
		[locked_icon setScale:0.58];
		
	} else if (mode == SpinButtonMode_OK) {
		[time_disp setVisible:NO];
		[cost_disp setVisible:YES];
		[locked_icon setVisible:NO];
		if (pressed) {
			[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"spinbutton_pressed"]];
			[cost_disp setPosition:[Common pct_of_obj:self pctx:0.5 pcty:0.265]];
		} else {
			[self setTextureRect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"spinbutton"]];
			[cost_disp setPosition:[Common pct_of_obj:self pctx:0.5 pcty:0.365]];
		}
	}
	
}

-(void)on_touch {
	if (!self.visible || self.locked) return;
	pressed = YES;
	[self update_image];
}

-(void)touch_move:(CGPoint)pt {
	if (!self.visible || self.locked) return;
	pt = [self convertToNodeSpace:pt];
	CGRect hitrect = [self hit_rect_local];
	if (!CGRectContainsPoint(hitrect, pt)) {
		pressed = NO;
	} else {
		pressed = YES;
	}
	[self update_image];
}

-(void)touch_end:(CGPoint)pt {
	if (!self.visible || self.locked) return;
	
	pt = [self convertToNodeSpace:pt];
	CGRect hitrect = [self hit_rect_local];
	if (pressed && CGRectContainsPoint(hitrect, pt)) {
		[self start_spin];
	}
	pressed = NO;
	[self update_image];
}

-(CGRect)hit_rect_local {
	float sto_sc = [self scale];
	[self setScale:1];
	CGRect hitrect = [self boundingBox];
	hitrect.origin = CGPointZero;
	[self setScale:sto_sc];
	return hitrect;
}

-(BOOL)locked {
	return mode == SpinButtonMode_LOCKED_BONES || mode == SpinButtonMode_LOCKED_TIME;
}


@end

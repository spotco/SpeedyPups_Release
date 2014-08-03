#import "ShopTabTouchButton.h"
#import "AudioManager.h"

@implementation ShopTabTouchButton
+(ShopTabTouchButton*)cons_pt:(CGPoint)pt text:(NSString*)text cb:(CallBack*)tcb {
	return [[ShopTabTouchButton node] cons_pt:pt text:text cb:tcb];
}
-(id)cons_pt:(CGPoint)pt text:(NSString*)text cb:(CallBack*)tcb {
	[super cons_pt:pt
			   tex:[Resource get_tex:TEX_NMENU_ITEMS]
		   texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"tshop_tabpane_tab"]
				cb:tcb];
	[self setAnchorPoint:ccp(0,0)];
	[self addChild:[[Common cons_label_pos:[Common pct_of_obj:self pctx:0.5 pcty:0.5]
									color:ccc3(0,0,0)
								 fontsize:17
									  str:text] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	tabcover = [CCSprite spriteWithTexture:[Resource get_tex:TEX_NMENU_ITEMS] rect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"tshop_tabcover"]];
	[tabcover setPosition:[Common pct_of_obj:self pctx:0.5 pcty:0]];
	[tabcover setVisible:NO];
	[self addChild:tabcover];
	tar_scale_y = 0.97;
	
	[self setScale:1];
	
	return self;
}

-(void)touch_begin:(CGPoint)pt {
	pt = [self convertToNodeSpace:pt];
	CGRect hitrect = [self hit_rect_local];
	if (CGRectContainsPoint(hitrect, pt)) {
		[self.cb.target performSelector:self.cb.selector withObject:self];
		[AudioManager playsfx:SFX_MENU_UP];
	}
}

-(void)update {
	[self setScaleY:(tar_scale_y-self.scaleY)/3.0+self.scaleY];
}

-(void)set_selected:(BOOL)t {
	if (t) {
		tar_scale_y = 1.05;
		[tabcover setVisible:YES];
	} else {
		tar_scale_y = 0.95;
		[tabcover setVisible:NO];
	}
}

-(CGRect)hit_rect_local {
	CGRect rect = [super hit_rect_local];
	rect.size.height += 30;
	rect.size.width *= CC_CONTENT_SCALE_FACTOR();
	
	return rect;
}
@end

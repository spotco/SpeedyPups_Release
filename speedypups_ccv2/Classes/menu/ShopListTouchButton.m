#import "ShopListTouchButton.h"
#import "ShopRecord.h"
#import "AudioManager.h"
#import "ObjectPool.h"

@implementation ShopListTouchButton {
	CCLabelTTF *name_disp, *price_disp;
	CCSprite *disp_sprite;
}
@synthesize sto_info;

+(ShopListTouchButton*)cons_pt:(CGPoint)pt info:(ItemInfo*)info cb:(CallBack *)tcb {
	return [[ObjectPool depool:[ShopListTouchButton class]] cons_pt:pt info:info cb:tcb];
}

-(void)repool {
	if ([self class] == [ShopListTouchButton class]) {
		[self set_selected:NO];
		sto_info = NULL;
		self.cb = NULL;
		[self setTexture:[Resource get_tex:TEX_BLANK]];
		[ObjectPool repool:self class:[ShopListTouchButton class]];
	}
}

-(id)init {
	self = [super init];
	if ([self class] == [ShopListTouchButton class]) {
		[super cons_pt:CGPointZero
				   tex:[Resource get_tex:TEX_NMENU_ITEMS]
			   texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"tshop_vscrolltab"]
					cb:NULL];
		
		[self setAnchorPoint:ccp(0.5,0.5)];
		[self csf_setScale:0.95];
		
		name_disp = [[[Common cons_label_pos:[Common pct_of_obj:self pctx:0.9 pcty:0.9]
												  color:ccc3(0,0,0)
											   fontsize:16
													str:@""] anchor_pt:ccp(1,1)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
		[self addChild:name_disp];
		
		price_disp = [[[Common cons_label_pos:[Common pct_of_obj:self pctx:0.9 pcty:0.5]
												   color:ccc3(200,30,30)
												fontsize:13
													 str:@""] anchor_pt:ccp(1,1)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
		[self addChild:price_disp];
		disp_sprite = [[CCSprite node] pos:[Common pct_of_obj:self pctx:0.25 pcty:0.5]];
		
		[self addChild:disp_sprite];
	}
	
	return self;
}

-(id)cons_pt:(CGPoint)pt info:(ItemInfo*)info cb:(CallBack *)tcb  {
	[self setTexture:[Resource get_tex:TEX_NMENU_ITEMS]];
	CGRect bbox = [FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"tshop_vscrolltab"];
	[self setPosition:ccp(
		pt.x+(bbox.size.width/2.0)*CC_CONTENT_SCALE_FACTOR(),
		pt.y-(bbox.size.height/2.0)*CC_CONTENT_SCALE_FACTOR()
	)];
	sto_info = info;
	self.cb = tcb;
	[self set_selected:NO];
	
	if ([info class] == [IAPItemInfo class]) {
		[name_disp set_label:info.short_name];
		[price_disp set_label:((IAPItemInfo*)info).iap_price];
		[disp_sprite setTexture:info.tex];
		[disp_sprite setTextureRect:info.rect];
		
	} else {
		[name_disp set_label:info.short_name];
		[price_disp set_label:strf("%d",info.price)];
		[disp_sprite setTexture:info.tex];
		[disp_sprite setTextureRect:info.rect];
	}
		
	return self;
}

-(id)set_screen_clipping_area:(CGRect)clippingrect {
	has_clipping_area = YES;
	clipping_area = clippingrect;
	return self;
}

-(void)touch_begin:(CGPoint)pt {
	CGPoint scrn_pt = pt;
	pt = [self convertToNodeSpace:pt];
	CGRect hitrect = [self hit_rect_local];
	if (CGRectContainsPoint(hitrect, pt)) {
		if (!CGRectContainsPoint(clipping_area, scrn_pt)) {
			return;
		}
		[self.cb.target performSelector:self.cb.selector withObject:self];
		[AudioManager playsfx:SFX_MENU_UP];
	}
}

-(CGRect)hit_rect_local {
	CGRect hitrect = [self boundingBox];
	hitrect.origin = CGPointZero;
	hitrect.size.width *= 1/self.scale;
	hitrect.size.height *= 1/self.scale;
	return hitrect;
}

-(void)update {
	[self csf_setScale:(tar_scale-self.csf_scale)/3.0+self.csf_scale];
}

-(void)set_selected:(BOOL)t {
	if (t) {
		tar_scale = 1;
		[[self parent] reorderChild:self z:5];
	} else {
		tar_scale = 0.85;
		[[self parent] reorderChild:self z:2];
	}
}
@end



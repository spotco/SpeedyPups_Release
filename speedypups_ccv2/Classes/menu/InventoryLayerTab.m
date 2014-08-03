#import "InventoryLayerTab.h"

@implementation InventoryLayerTab

+(InventoryLayerTab*)cons_pt:(CGPoint)pt text:(NSString *)str cb:(CallBack *)cb {
	return [[InventoryLayerTab node] cons_pt:pt text:str cb:cb];
}
-(id)cons_pt:(CGPoint)pt text:(NSString*)text cb:(CallBack*)tcb {
	[super cons_pt:pt
			   tex:[Resource get_tex:TEX_NMENU_ITEMS]
		   texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"tshop_tabpane_tab"]
				cb:tcb];
	[self setAnchorPoint:ccp(0,0)];
	[self addChild:[[Common cons_label_pos:[Common pct_of_obj:self pctx:0.5/ CC_CONTENT_SCALE_FACTOR() pcty:0.25]
									color:ccc3(0,0,0)
								 fontsize:14
									  str:text] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	
	tar_scale_y = 0.97;
	
	tabcover = [CCSprite spriteWithTexture:[Resource get_tex:TEX_NMENU_ITEMS] rect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"tshop_tabcover"]];
	[tabcover setPosition:[Common pct_of_obj:self pctx:0.5 / CC_CONTENT_SCALE_FACTOR() pcty:0]];
	[tabcover setVisible:NO];
	[self addChild:tabcover];
	
	[self setScale:1];
	
	return self;
}

-(void)set_selected:(BOOL)t {
	tar_scale_y = t ? 1.1 : 0.95;
	[tabcover setVisible:t];
}

-(void)update {
	[self setScaleY:(tar_scale_y-self.scaleY)/3.0+self.scaleY];
}

-(CGRect)boundingBox {
	CGRect rtv = [super boundingBox];
	rtv.size.height+=30;
	rtv.size.width *= CC_CONTENT_SCALE_FACTOR();
	return rtv;
}

@end


@implementation PollingButton

+(PollingButton*)cons_pt:(CGPoint)pt
				  texkey:(NSString *)texkey
				  yeskey:(NSString *)yeskey
				   nokey:(NSString *)nokey
					poll:(CallBack *)poll
				   click:(CallBack *)click {
	return [[PollingButton node] cons_pt:pt texkey:texkey yeskey:yeskey nokey:nokey poll:poll click:click];
}

-(id)cons_pt:(CGPoint)_pt
	  texkey:(NSString *)_texkey
	  yeskey:(NSString *)_yeskey
	   nokey:(NSString *)_nokey
		poll:(CallBack *)_poll
	   click:(CallBack *)_click {
	
	yes = [FileCache get_cgrect_from_plist:_texkey idname:_yeskey];
	no = [FileCache get_cgrect_from_plist:_texkey idname:_nokey];
	poll = _poll;
	
	[super cons_pt:_pt
			   tex:[Resource get_tex:_texkey]
		   texrect:CGRectZero
				cb:_click];
	[self setTextureRect:[poll.target performSelector:poll.selector]?yes:no];
	
	return self;
}

-(void)on_touch {
	[super on_touch];
	[self setTextureRect:[poll.target performSelector:poll.selector]?yes:no];
}

@end
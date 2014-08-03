#import "InventoryLayerTabScrollList.h"
#import "Common.h"
#import "Resource.h"
#import "FileCache.h"
#import "ShopListTouchButton.h"
#import "ShopRecord.h"
#import "GameItemCommon.h"
#import "ObjectPool.h"

@implementation InventoryLayerTabScrollList

+(InventoryLayerTabScrollList*)cons_parent:(CCSprite *)parent add_to:(CCSprite *)add_to {
	return [[[InventoryLayerTabScrollList alloc] init] cons_parent:parent add_to:add_to];
}

-(id)cons_parent:(CCSprite *)parent add_to:(CCSprite *)add_to {
	
	CCSprite *divider = [CCSprite spriteWithTexture:[Resource get_tex:TEX_NMENU_ITEMS]
											   rect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"inventorydivider"]];
	[divider setRotation:90];
	[divider setScale:0.475];
	[divider setPosition:[Common pct_of_obj:parent pctx:0.31 pcty:0.5]];
	[add_to addChild:divider];
	
	clipper = [ClippingNode node];
	
	CGPoint clipper_l_anchor = ccp(
			parent.position.x - [parent boundingBox].size.width/2.0,
			parent.position.y - [parent boundingBox].size.height/2.0
	);
	
	[clipper setClippingRegion:CGRectMake(
										  clipper_l_anchor.x + 10,
										  clipper_l_anchor.y + 13,
										  [parent boundingBox].size.width * 0.4 - 20,
										  [parent boundingBox].size.height * 0.96 - 20
										  )];
	clipperholder = [CCSprite node];
	
	clipper_anchor = ccp( 10,clipper.clippingRegion.size.height + 10);
	clippedholder_y_min = 0;
	[clipper addChild:clipperholder];
	
	can_scroll_down = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"scroll_arrow"]];
	[can_scroll_down setScaleY:-1];
	can_scroll_up = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"scroll_arrow"]];
	[can_scroll_down setPosition:[Common pct_of_obj:parent pctx:0.16 pcty:0.035]];
	[can_scroll_up setPosition:[Common pct_of_obj:parent pctx:0.16 pcty:0.95]];
	
	
	
	[add_to addChild:[MenuCommon cons_descaler_for:clipper pos:CGPointZero]];
	[add_to addChild:can_scroll_down];
	[add_to addChild:can_scroll_up];
	is_scroll = NO;
	
	touches = [NSMutableArray array];
	
	mult = 0;
	
	return self;
}

-(GenericListTouchButton*)add_tab:(CCTexture2D *)tex rect:(CGRect)rect main_text:(NSString *)main_text sub_text:(NSString *)sub_text callback:(CallBack *)cb {
	CGRect bbox = [FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"tshop_vscrolltab"];
	bbox.size.height *= CC_CONTENT_SCALE_FACTOR();
	GenericListTouchButton *tmp = [[GenericListTouchButton cons_pt:ccp(clipper_anchor.x,clipper_anchor.y - bbox.size.height * mult)
														   texrect:[TexRect cons_tex:tex rect:rect]
															   val:cb
																cb:[Common cons_callback:self sel:@selector(sellist:)]]
								   set_screen_clipping_area:clipper.clippingRegion];
	[tmp set_main_text:main_text];
	[tmp set_sub_text:sub_text];
	if (bbox.size.height * (mult + 1) + 15 > clipper.clippingRegion.size.height) {
		clippedholder_y_max = MAX(clippedholder_y_max, bbox.size.height * (mult + 1) + 15 - clipper.clippingRegion.size.height);
	}
	
	[touches addObject:tmp];
	[clipperholder addChild:tmp];
	mult++;
	
	return tmp;
}

-(int)get_num_tabs {
	return (int)[touches count];
}

-(void)clear_tabs {
	for (GenericListTouchButton *i in touches) {
		[clipperholder removeChild:i cleanup:YES];
		[i repool];
	}
	[touches removeAllObjects];
	mult = 0;
	clippedholder_y_max = 0;
}

-(void)sellist:(id)obj {
	GenericListTouchButton *btn = (GenericListTouchButton *)obj;
	for (TouchButton *i in touches) {
		if ([i class] == [GenericListTouchButton class]) {
			[(GenericListTouchButton*)i set_selected:NO];
		}
	}
	[btn set_selected:YES];
	
	[Common run_callback:btn.val];
}

-(void)update {
	CGPoint neupos = CGPointAdd(ccp(0,vy), clipperholder.position);
	neupos.y = clampf(neupos.y, clippedholder_y_min, clippedholder_y_max);
	[clipperholder setPosition:neupos];
	vy *= 0.8;
	[can_scroll_up setVisible:neupos.y != clippedholder_y_min];
	[can_scroll_down setVisible:neupos.y != clippedholder_y_max];
	
	for (TouchButton *i in touches) {
		if ([i class] == [GenericListTouchButton class]) {
			[((GenericListTouchButton*)i) update];
		}
	}
}

-(void)touch_begin:(CGPoint)pt {
	for (int i = (int)touches.count-1; i>=0; i--) {
		TouchButton *b = touches[i];
		[b touch_begin:pt];
	}
	
	is_scroll = YES;
	last_scroll_pt = pt;
	scroll_move_ct = 0;
}

-(void)touch_move:(CGPoint)pt {
	if (!is_scroll) return;
	CGPoint ydelta = ccp(0,-last_scroll_pt.y+pt.y);
	last_scroll_pt = pt;
	
	float sign = [Common sig:ydelta.y];
	float av = 15.0*MIN(ABS(ydelta.y),30)/30.0;
	av /= MAX(1,8.0-scroll_move_ct);
	vy += sign * av;
	scroll_move_ct++;
}

-(void)touch_end:(CGPoint)pt {
	is_scroll = NO;
}

-(void)dealloc {
	[self clear_tabs];
}

@end


@implementation GenericListTouchButton
@synthesize val;
+(GenericListTouchButton*)cons_pt:(CGPoint)pt texrect:(TexRect *)texrect val:(CallBack*)val cb:(CallBack *)tcb {
	return [[ObjectPool depool:[GenericListTouchButton class]] cons_pt:pt texrect:texrect val:val cb:tcb];
}

-(void)repool {
	if ([self class] == [GenericListTouchButton class]) {
		[self set_selected:NO];
		val = NULL;
		self.cb = NULL;
		[self setTexture:[Resource get_tex:TEX_BLANK]];
		[ObjectPool repool:self class:[GenericListTouchButton class]];
	}
}

-(id)init {
	self = [super init];
	if ([self class] == [GenericListTouchButton class]) {
		[super cons_pt:CGPointZero
				   tex:[Resource get_tex:TEX_NMENU_ITEMS]
			   texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"tshop_vscrolltab"]
					cb:NULL];
		[self setAnchorPoint:ccp(0.5,0.5)];
		main_text = [[[Common cons_label_pos:[Common pct_of_obj:self pctx:0.9 pcty:0.9]
									  color:ccc3(0,0,0)
								   fontsize:16
										str:@""] anchor_pt:ccp(1,1)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
		[self addChild:main_text];
		
		sub_text = [[[Common cons_label_pos:[Common pct_of_obj:self pctx:0.9 pcty:0.5]
									 color:ccc3(200,30,30)
								  fontsize:13
									   str:@""] anchor_pt:ccp(1,1)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
		[self addChild:sub_text];
		
		disp_sprite = [[CCSprite node] pos:[Common pct_of_obj:self pctx:0.25 pcty:0.5]];
		[self addChild:disp_sprite];
		
		[self csf_setScale:0.95];
		[self set_selected:NO];
	}
	
	return self;
}

-(id)cons_pt:(CGPoint)pt texrect:(TexRect *)texrect val:(CallBack*)_val cb:(CallBack *)tcb {
	CGRect bbox = [FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"tshop_vscrolltab"];
	bbox.size.width *= CC_CONTENT_SCALE_FACTOR();
	bbox.size.height *= CC_CONTENT_SCALE_FACTOR();
	[self setTexture:[Resource get_tex:TEX_NMENU_ITEMS]];
	[self setPosition:ccp(pt.x+bbox.size.width/2.0,pt.y-bbox.size.height/2.0)];
	
	self.val = _val;
	self.cb = tcb;
	
	[self csf_setScale:0.95];
	
	[disp_sprite setTexture:texrect.tex];
	[disp_sprite setTextureRect:texrect.rect];
	[self set_selected:NO];
	return self;
}

-(void)set_main_text:(NSString *)s {
	[main_text set_label:s];
}

-(void)set_sub_text:(NSString *)s {
	[sub_text set_label:s];
}

@end

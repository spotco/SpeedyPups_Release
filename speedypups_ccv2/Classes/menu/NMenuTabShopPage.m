#import "NMenuTabShopPage.h"
#import "Shopkeeper.h"
#import "MenuCommon.h"
#import "ShopTabTouchButton.h"
#import "InventoryLayerTab.h"
#import "UserInventory.h"
#import "Particle.h"
#import "ShopBuyBoneFlyoutParticle.h"
#import "ShopBuyFlyoffTextParticle.h"
#import "AudioManager.h"
#import "ShopListTouchButton.h" 
#import "SpeedyPupsIAP.h"

@implementation NMenuTabShopPage {
	ShopTabTouchButton *iap_tab;
}

+(NMenuTabShopPage*)cons {
	return [NMenuTabShopPage node];
}

#define t_SHOPKEEPER 0
#define t_SHOPSIGN 1
#define t_TOTALBONESPANE 2
-(id)init {
	self = [super init];
	[GEventDispatcher add_listener:self];
	scroll_items = [NSMutableArray array];
	current_tab = ShopTab_UPGRADE;
	[self addChild:[Shopkeeper cons_pt:[Common screen_pctwid:0.1 pcthei:0.45]] z:0 tag:t_SHOPKEEPER];
	[self addChild:[MenuCommon menu_item:TEX_NMENU_ITEMS id:@"nmenu_shopsign" pos:[Common screen_pctwid:0.1 pcthei:0.88]] z:0 tag:t_SHOPSIGN];
	[self addChild:[MenuCommon cons_common_nav_menu]];
	
	
	tabbedpane = [[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_NMENU_ITEMS]
												   rect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"tshop_tabbedshoppane"]]
							pos:[Common screen_pctwid:0.615 pcthei:0.55]];
	
	touches = [NSMutableArray array];
	
	CGPoint tabanchor = [Common pct_of_obj:tabbedpane pctx:0 pcty:0.99];
	CGSize tabsize = [FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"tshop_tabpane_tab"].size;
	ShopTabTouchButton *first_tab = [self cons_tab_pos:tabanchor sel:@selector(tab0:) text:@"Items" parent:tabbedpane];
	[first_tab set_selected:YES];
	cur_selected_tab = first_tab;
	[self cons_tab_pos:ccp(tabanchor.x + tabsize.width,tabanchor.y) sel:@selector(tab1:) text:@"Dogs" parent:tabbedpane];
	[self cons_tab_pos:ccp(tabanchor.x + tabsize.width*2,tabanchor.y) sel:@selector(tab2:) text:@"Extras" parent:tabbedpane];
	iap_tab = [self cons_tab_pos:ccp(tabanchor.x + tabsize.width*3,tabanchor.y) sel:@selector(tab3:) text:@"$$$" parent:tabbedpane];
	
	
	clipper = [ClippingNode node];
	CGPoint clipper_l_anchor = ccp(
		tabbedpane.position.x - [tabbedpane boundingBox].size.width/2.0,
		tabbedpane.position.y - [tabbedpane boundingBox].size.height/2.0
	);
	
	[clipper setClippingRegion:CGRectMake(
		clipper_l_anchor.x + 10,
	    clipper_l_anchor.y + 13,
		[tabbedpane boundingBox].size.width * 0.4 - 20,
		[tabbedpane boundingBox].size.height * 0.96 - 20
	)];
	clipperholder = [CCSprite node];
	
	clipper_anchor = ccp( 10, clipper.clippingRegion.size.height + 10);
	clippedholder_y_min = 0;
	[clipper addChild:clipperholder];
	
	[tabbedpane addChild:[MenuCommon cons_descaler_for:clipper pos:CGPointZero]];
	
	can_scroll_down = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"scroll_arrow"]];
	[can_scroll_down setScaleY:-1];
	can_scroll_up = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"scroll_arrow"]];
	[can_scroll_down setPosition:[Common pct_of_obj:tabbedpane pctx:0.2 pcty:0.035]];
	[can_scroll_up setPosition:[Common pct_of_obj:tabbedpane pctx:0.2 pcty:0.95]];
	[tabbedpane addChild:can_scroll_down];
	[tabbedpane addChild:can_scroll_up];
	
	
	itemname = [[[Common cons_label_pos:[Common pct_of_obj:tabbedpane pctx:0.43 pcty:0.935]
								color:ccc3(200,30,30)
							 fontsize:24
								  str:@"Item Name"] anchor_pt:ccp(0,1)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[tabbedpane addChild:itemname];
	
	price_disp = [CCSprite node];
	[price_disp addChild:[[[Common cons_label_pos:[Common pct_of_obj:tabbedpane pctx:0.43 pcty:0.51]
										  color:ccc3(200,30,30)
									   fontsize:16
											str:@"Price"] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	itemprice = [[[Common cons_label_pos:[Common pct_of_obj:tabbedpane pctx:0.555 pcty:0.385]
								 color:ccc3(0,0,0)
							  fontsize:30
								   str:@"99999"] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[price_disp addChild:itemprice];
	itemprice_x = [[Common cons_label_pos:[Common pct_of_obj:tabbedpane pctx:0.535 pcty:0.385]
								   color:ccc3(0,0,0)
								fontsize:12
									 str:@"x"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[price_disp addChild:itemprice_x];
	itemprice_icon = [CCSprite spriteWithTexture:[Resource get_tex:TEX_NMENU_ITEMS]
											rect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"coin"]];
	[itemprice_icon pos:[Common pct_of_obj:tabbedpane pctx:0.47 pcty:0.385]];
	[price_disp addChild:itemprice_icon];
						  
	[tabbedpane addChild:price_disp];
	
	buy_button_pane = [CCSprite node];
	[tabbedpane addChild:buy_button_pane];
	
	buybutton = [AnimatedTouchButton cons_pt:CGPointZero
								 tex:[Resource get_tex:TEX_NMENU_ITEMS]
							 texrect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"buybutton"]
								  cb:[Common cons_callback:self sel:@selector(buybutton)]];
	[buybutton setPosition:ccp(buybutton.position.x - buybutton.boundingBox.size.width/2.0, buybutton.position.y + buybutton.boundingBox.size.height/2.0 )];
	[touches addObject:buybutton];
	
	CCSprite *buybutton_reverse_scale = [CCSprite node];
	[buybutton_reverse_scale setScale:1/CC_CONTENT_SCALE_FACTOR()];
	[buybutton_reverse_scale addChild:buybutton];
	[buybutton_reverse_scale setPosition:[Common pct_of_obj:tabbedpane pctx:0.975 pcty:0.025]];
	[buy_button_pane addChild:buybutton_reverse_scale];
	
	notenoughdisp = [[Common cons_label_pos:[Common pct_of_obj:tabbedpane pctx:0.69 pcty:0.15]
									 color:ccc3(200,30,30)
								  fontsize:23
									   str:@"Not enough coins!"] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[buy_button_pane addChild:notenoughdisp];
	
	loading_button_pane = [CCSprite node];
	[loading_button_pane addChild:[[Common cons_label_pos:[Common pct_of_obj:tabbedpane pctx:0.69 pcty:0.15]
									 color:ccc3(200,30,30)
								  fontsize:23
									   str:@"Loading..."] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	[tabbedpane addChild:loading_button_pane];
	[buy_button_pane setVisible:YES];
	[loading_button_pane setVisible:NO];
	
	NSString* maxstr = @"aaaaaaaaaaaaaaaaaaaaaaaa\naaaaaaaaaaaaaaaaaaaaaaaa\naaaaaaaaaaaaaaaaaaaaaaaa";
    CGSize actualSize = [maxstr sizeWithFont:[UIFont fontWithName:@"Carton Six" size:15]
                           constrainedToSize:CGSizeMake(1000, 1000)
                               lineBreakMode:(NSLineBreakMode)UILineBreakModeWordWrap];
	itemdesc = [[CCLabelTTF labelWithString:@""
								dimensions:actualSize
								 alignment:UITextAlignmentLeft
								  fontName:@"Carton Six"
								   fontSize:13] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[itemdesc setAnchorPoint:ccp(0,1)];
	[itemdesc setColor:ccc3(0,0,0)];
	[itemdesc setPosition:[Common pct_of_obj:tabbedpane pctx:0.44 pcty:0.79]];
	[tabbedpane addChild:itemdesc];
	[self addChild:tabbedpane];
	
	CCSprite *total_bones_pane = [[CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
														 rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"continue_total_bg"]]
								  pos:[Common screen_pctwid:0.13 pcthei:0.3]];
	[total_bones_pane addChild:[[[CCSprite spriteWithTexture:[Resource get_tex:TEX_NMENU_ITEMS]
													   rect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"coin"]
								 ] pos:[Common pct_of_obj:total_bones_pane pctx:0.15 pcty:0.3]] scale:0.6]];
	[total_bones_pane addChild:[[Common cons_label_pos:[Common pct_of_obj:total_bones_pane pctx:0.365 pcty:0.75]
												color:ccc3(0,0,0)
											 fontsize:10
												  str:@"Total Coins"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	[total_bones_pane addChild:[[Common cons_label_pos:[Common pct_of_obj:total_bones_pane pctx:0.32 pcty:0.325]
												color:ccc3(200,30,30)
											 fontsize:10
												  str:@"x"] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	total_disp = [[[Common cons_label_pos:[Common pct_of_obj:total_bones_pane pctx:0.38 pcty:0.325]
								  color:ccc3(200,30,30)
							   fontsize:20
									str:@"000000"] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[total_disp setString:strf("%d",[UserInventory get_current_coins])];
	[total_bones_pane addChild:total_disp];
	[self addChild:total_bones_pane z:0 tag:t_TOTALBONESPANE];
	
	particles = [NSMutableArray array];
	particleholder = [CCSprite node];
	[self addChild:particleholder];
	
	[self make_scroll_items];
	return self;
}

-(void)remove_all_scroll_items {
	for (int i = 0; i < scroll_items.count; i++) {
		[(ShopListTouchButton*)scroll_items[i] repool];
		[((CCSprite*)scroll_items[i]).parent removeChild:scroll_items[i] cleanup:YES];
		[touches removeObject:scroll_items[i]];
	}
	[scroll_items removeAllObjects];
	clippedholder_y_min = 0;
	clippedholder_y_max = 0;
}

-(void)make_scroll_items {
	[self remove_all_scroll_items];
	
	NSArray *items = [ShopRecord get_items_for_tab:current_tab];
	for (int i = 0; i < items.count; i++) {
		ItemInfo *info = items[i];
		ShopListTouchButton *neu = 
			[self cons_scrollitem_anchor:clipper_anchor
									mult:i
									info:info
								  parent:clipperholder
									clip:clipper.clippingRegion];
		[scroll_items addObject:neu];
	}
	
	if (items.count > 0) {
		[itemdesc setVisible:YES];
		[price_disp setVisible:YES];
		[buybutton setVisible:YES];
		current_scroll_index = current_scroll_index < scroll_items.count ? current_scroll_index : (int)scroll_items.count - 1;
		[self sellist:scroll_items[current_scroll_index]];
		
	} else {
		itemname.string = @"More Coming Soon!";
		[itemdesc setVisible:NO];
		[price_disp setVisible:NO];
		[buybutton setVisible:NO];
		[notenoughdisp setVisible:NO];
	}
}

-(ShopListTouchButton*)cons_scrollitem_anchor:(CGPoint)anchor mult:(int)mult info:(ItemInfo*)info parent:(CCNode*)parent clip:(CGRect)clip {
	CGRect bbox = [FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"tshop_vscrolltab"];
	bbox.size.height *= CC_CONTENT_SCALE_FACTOR();
	ShopListTouchButton *tmp = [[ShopListTouchButton cons_pt:ccp(anchor.x,anchor.y - (bbox.size.height * mult))
														info:info
														  cb:[Common cons_callback:self sel:@selector(sellist:)]]
						set_screen_clipping_area:clip];
	if (bbox.size.height * (mult + 1) + 15 > clip.size.height) {
		clippedholder_y_max = MAX(clippedholder_y_max, bbox.size.height * (mult + 1) + 15 - clip.size.height);
	}
	
	[touches addObject:tmp];
	[parent addChild:tmp];
	return tmp;
}

-(ShopTabTouchButton*)cons_tab_pos:(CGPoint)pt sel:(SEL)sel text:(NSString*)str parent:(CCSprite*)parent{
	ShopTabTouchButton *tab1 = [ShopTabTouchButton cons_pt:pt text:str cb:[Common cons_callback:self sel:sel]];
	[touches addObject:tab1];
	[parent addChild:tab1 z:0];
	return tab1;
}

-(void)sellist:(ShopListTouchButton*)tar {
	if (cur_selected_list_button != NULL) {
		[cur_selected_list_button set_selected:NO];
	}
	for (int i = 0; i < scroll_items.count; i++) {
		if (scroll_items[i] == tar) {
			current_scroll_index = i;
			break;
		}
	}
	cur_selected_list_button = tar;
	[tar set_selected:YES];
	
	itemname.string = tar.sto_info.name;
	itemdesc.string = tar.sto_info.desc;
	itemprice.string = [NSString stringWithFormat:@"%d",tar.sto_info.price];
	
	sto_val = tar.sto_info.val;
	sto_price = tar.sto_info.price;
	
	if ([tar.sto_info class] == [IAPItemInfo class]) {
		[itemprice_x setVisible:NO];
		[itemprice_icon setTextureRect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"money_icon"]];
		itemprice.string = ((IAPItemInfo*)tar.sto_info).iap_price;
		[itemprice setPosition:[Common pct_of_obj:tabbedpane pctx:0.51 pcty:0.385]];
		
	} else {
		[itemprice_x setVisible:YES];
		[itemprice_icon setTextureRect:[FileCache get_cgrect_from_plist:TEX_NMENU_ITEMS idname:@"coin"]];
		[itemprice setPosition:[Common pct_of_obj:tabbedpane pctx:0.555 pcty:0.385]];
	}
	
	if (sto_price > [UserInventory get_current_coins]) {
		[buybutton setVisible:NO];
		[notenoughdisp setVisible:YES];
	} else {
		[buybutton setVisible:YES];
		[notenoughdisp setVisible:NO];
	}
}

-(void)seltab:(int)t tab:(ShopTabTouchButton*)tab{
	if (cur_selected_tab != NULL) {
		[cur_selected_tab set_selected:NO];
	}
	cur_selected_tab = tab;
	[tab set_selected:YES];
	
	current_tab = t==0?ShopTab_UPGRADE:
					(t==1?ShopTab_CHARACTERS:
					 (t==2?ShopTab_UNLOCK:ShopTab_REALMONEY));
	current_tab_index = t;
	[self make_scroll_items];
}

-(void)tab0:(ShopTabTouchButton*)tab{current_scroll_index = 0;[self seltab:0 tab:tab];}
-(void)tab1:(ShopTabTouchButton*)tab{current_scroll_index = 0;[self seltab:1 tab:tab];}
-(void)tab2:(ShopTabTouchButton*)tab{current_scroll_index = 0;[self seltab:2 tab:tab];}
-(void)tab3:(ShopTabTouchButton*)tab{current_scroll_index = 0;[self seltab:3 tab:tab];}


-(void)open_iap_tab_and_buy_adfree {
	[self seltab:3 tab:iap_tab];
	ShopListTouchButton *tar_btn = NULL;
	for (ShopListTouchButton *btn in scroll_items) {
		if ([btn.sto_info class] == [IAPItemInfo class] && streq(((IAPItemInfo*)btn.sto_info).iap_identifier,SPEEDYPUPS_AD_FREE)) {
			tar_btn = btn;
		}
	}
	if (tar_btn) {
		[self sellist:tar_btn];
		[self buybutton];
	}
}

-(void)dispatch_event:(GEvent *)e {
	if (e.type == GEventType_OPEN_IAP_TAB_AND_BUY_ADFREE) {
		[self open_iap_tab_and_buy_adfree];
		
    } else if (e.type == GEventType_MENU_INVENTORY) {
        [tabbedpane setVisible:NO];
		[[self getChildByTag:t_SHOPKEEPER] setVisible:NO];
		[[self getChildByTag:t_SHOPSIGN] setVisible:NO];
		[[self getChildByTag:t_TOTALBONESPANE] setVisible:NO];
        
    } else if (e.type == GEVentType_MENU_CLOSE_INVENTORY) {
        [tabbedpane setVisible:YES];
		[[self getChildByTag:t_SHOPKEEPER] setVisible:YES];
		[[self getChildByTag:t_SHOPSIGN] setVisible:YES];
		[[self getChildByTag:t_TOTALBONESPANE] setVisible:YES];
        
    } else if (e.type == GEventType_MENU_TICK && self.visible) {
		[self update];
		
	} else if (e.type == GEventType_IAP_BUY) {
		[buy_button_pane setVisible:NO];
		[loading_button_pane setVisible:YES];
		[self make_scroll_items];
		
	} else if (e.type == GEventType_IAP_SUCCESS || e.type == GEventType_IAP_FAIL) {
		[buy_button_pane setVisible:YES];
		[loading_button_pane setVisible:NO];
		if (e.type == GEventType_IAP_FAIL) {
			if (e.i1 == 1) {
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not connect to the App Store!"
																message:@""
															   delegate:NULL
													  cancelButtonTitle:@"Ok"
													  otherButtonTitles:NULL];
				[alert show];
			}
		}
		[self make_scroll_items];
	}
}

-(void)update {
	if (![self visible]) return;
	
	for (id obj in touches) if ([obj respondsToSelector:@selector(update)]) [obj update];
	
	CGPoint neupos = CGPointAdd(ccp(0,vy), clipperholder.position);
	neupos.y = clampf(neupos.y, clippedholder_y_min, clippedholder_y_max);
	[clipperholder setPosition:neupos];
	vy *= 0.8;
	[can_scroll_up setVisible:neupos.y != clippedholder_y_min];
	[can_scroll_down setVisible:neupos.y != clippedholder_y_max];
	
	for (TouchButton *i in touches) {
		if ([i class] == [ShopListTouchButton class]) {
			[((ShopListTouchButton*)i) update];
		}
		if ([i class] == [ShopTabTouchButton class]) {
			[((ShopTabTouchButton*)i) update];
		}
	}
	
	[buybutton csf_setScale:((1-buybutton.csf_scale)/5.0+buybutton.csf_scale)];
	
	NSMutableArray *toremove = [NSMutableArray array];
    for (Particle *i in particles) {
        [i update:(id)self];
        if ([i should_remove]) {
            [particleholder removeChild:i cleanup:YES];
            [toremove addObject:i];
        }
    }
	[particles removeObjectsInArray:toremove];
	
	int curdispval = (int)total_disp.string.integerValue;
	int tardispval = [UserInventory get_current_coins];
	if (curdispval != tardispval) {
		if (ABS(curdispval-tardispval) > 200) {
			curdispval = curdispval + (tardispval-curdispval)/10.0f;
		} else {
			curdispval = tardispval;
		}
		[total_disp setString:strf("%d",curdispval)];
	}
}

-(void)add_particle:(Particle*)p {
	[particleholder addChild:p];
	[particles addObject:p];
}

-(void)buybutton {
	if ([ShopRecord buy_shop_item:sto_val price:sto_price]) {
		CGPoint centre = [buybutton convertToWorldSpace:CGPointZero];
		centre.x += buybutton.boundingBox.size.width/2.0f;
		centre.y += buybutton.boundingBox.size.height/2.0f;
		if (sto_price != 0) {
			centre = [total_disp convertToWorldSpace:CGPointZero];
			[self add_particle:[ShopBuyFlyoffTextParticle cons_pt:ccp(centre.x+total_disp.boundingBox.size.width/2.0,centre.y+15) text:strf("-%d",sto_price)]];
		}
		[self seltab:current_tab_index tab:cur_selected_tab];
		[AudioManager playsfx:SFX_BUY];
		[AudioManager playsfx:SFX_BARK_MID];
		
		[GEventDispatcher push_event:[GEvent cons_type:GeventType_MENU_UPDATE_INVENTORY]];
		
	} else {
		NSLog(@"buying failed");
	}
}

-(void)touch_begin:(CGPoint)pt {
	if (!self.visible) return;
	for (int i = (int)touches.count-1; i >= 0; i--) [(TouchButton*)touches[i] touch_begin:pt];
	
	is_scroll = YES;
	last_scroll_pt = pt;
	scroll_move_ct = 0;
}

-(void)touch_move:(CGPoint)pt {
	if (![self visible]) return;
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
	if (!self.visible) return;
	for (int i = (int)touches.count-1; i >= 0; i--) [(TouchButton*)touches[i] touch_end:pt];
	is_scroll = NO;
}

-(void)dealloc {
	[self remove_all_scroll_items];
	[touches removeAllObjects];
	[particles removeAllObjects];
	[scroll_items removeAllObjects];
	[self removeAllChildrenWithCleanup:YES];
}

@end

#import "InventoryTabPane_Prizes.h"
#import "Common.h"
#import "MenuCommon.h"
#import "SpinButton.h"
#import "DataStore.h"
#import "UserInventory.h"
#import "Particle.h"
#import "ShopBuyBoneFlyoutParticle.h" 
#import "ShopBuyFlyoffTextParticle.h"
#import "BoneCollectUIAnimation.h"
#import "AudioManager.h"
#import "BasePopup.h"
#import "DailyLoginPrizeManager.h"
#import "ExtrasManager.h"
#import "ExtrasUnlockPopup.h"
#import "DailyLoginPopup.h"
#import "Player.h"
#import "TrackingUtil.h"

typedef enum PrizesPaneMode {
	PrizesPaneMode_REST,
	PrizesPaneMode_SPINNING
} PrizesPaneMode;

typedef enum Prize {
	Prize_ManyCoin,
	Prize_ManyBone,
	Prize_Coin,
	Prize_Bone,
	Prize_Mystery,
	Prize_None
} Prize;

@interface PrizeIcon : CCSprite
@property(readwrite,assign) Prize prize_type;
@end
@implementation PrizeIcon
@synthesize prize_type;
@end

@implementation InventoryTabPane_Prizes {
	NSMutableArray *touches;
	NSMutableArray *lights;
	NSMutableArray *prizes;
	
	NSMutableArray *particles;
	CCSprite *particle_holder;
	
	CCSprite *wheel_pointer;
	float wheel_pointer_vr;
	SpinButton *spinbutton;
	
	CCLabelTTF *cur_bones_disp;
	CCLabelTTF *cur_coins_disp;
	CCLabelTTF *reset_in_disp;
	
	PrizesPaneMode mode;
	float disp_bones;
	
	int last_light;
}

+(InventoryTabPane_Prizes*)cons:(CCSprite *)parent {
	return [[InventoryTabPane_Prizes node] cons:parent];
}

-(id)cons:(CCSprite*)parent {
	touches = [NSMutableArray array];
	prizes = [NSMutableArray array];
	
	particles = [NSMutableArray array];
	particle_holder = [CCSprite node];
	[self addChild:particle_holder z:5];
	
	mode = PrizesPaneMode_REST;
	disp_bones = [UserInventory get_current_bones];
	CCSprite *wheel_label = [[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
													rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"wheelofprizes"]]
							 pos:[Common pct_of_obj:parent pctx:0.15 pcty:0.725]];
	[wheel_label setScale:0.5];
	[self addChild:wheel_label];
	
	
	[self addChild:[[Common cons_label_pos:[Common pct_of_obj:parent pctx:0.84 pcty:0.86]
									color:ccc3(20,20,20)
								 fontsize:14
									  str:@"Wheel Resets In..."] set_scale:1/CC_CONTENT_SCALE_FACTOR()]];
	
	reset_in_disp = [[Common cons_label_pos:[Common pct_of_obj:parent pctx:0.84 pcty:0.75]
									   color:ccc3(200,30,30)
									fontsize:34
										 str:@""] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[reset_in_disp setColor:ccc3(200,30,30)];
	[self addChild:reset_in_disp];
	
	CCSprite *bones_disp_bg = [[[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
													 rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"currency_bones_disp"]]
							   pos:[Common pct_of_obj:parent pctx:0.02 pcty:0.25]] anchor_pt:ccp(0,0.5)];
	[self addChild:bones_disp_bg];
	
	cur_bones_disp = [[[Common cons_label_pos:[Common pct_of_obj:bones_disp_bg pctx:0.2 pcty:0.5]
									  color:ccc3(200,30,30)
								   fontsize:20
										str:@""] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[bones_disp_bg addChild:cur_bones_disp];
	
	
	CCSprite *coins_disp_bg = [[[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
													   rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"currency_coins_disp"]]
								pos:[Common pct_of_obj:parent pctx:0.02 pcty:0.1]] anchor_pt:ccp(0,0.5)];
	[self addChild:coins_disp_bg];
	
	cur_coins_disp = [[[Common cons_label_pos:[Common pct_of_obj:coins_disp_bg pctx:0.2 pcty:0.5]
									   color:ccc3(200,30,30)
									fontsize:20
										 str:@""] anchor_pt:ccp(0,0.5)] set_scale:1/CC_CONTENT_SCALE_FACTOR()];
	[coins_disp_bg addChild:cur_coins_disp];
	
	CCSprite *wheel_bg = [[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
												 rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"menu_wheel_back"]]
						  pos:[Common pct_of_obj:parent pctx:0.5 pcty:0.5]];
	[self addChild:wheel_bg];
	
	wheel_pointer = [[[CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
										   rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"menu_wheel_point"]]
					anchor_pt:ccp(0.5,0.246)]
					pos:[Common pct_of_obj:wheel_bg pctx:0.5 pcty:0.5]];
	
	lights = [NSMutableArray array];
	for (float i = 0; i < 3.14 * 2; i += 3.14/6) {
		CCSprite *light = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
												 rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"menu_wheel_light_off"]];
		
		CGPoint tar_pos = ccp(0.5,0.5);
		Vec3D v = [VecLib scale:[VecLib cons_x:cosf(i+[Common deg_to_rad:15]) y:sinf(i+[Common deg_to_rad:15]) z:0] by:0.54];
		tar_pos.x += v.x;
		tar_pos.y += v.y;
		[light setPosition:[Common pct_of_obj:wheel_bg pctx:tar_pos.x pcty:tar_pos.y]];
		[wheel_bg addChild:light];
		[lights addObject:light];
		
		PrizeIcon *prize_icon = [PrizeIcon spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS] rect:CGRectZero];
		prize_icon.prize_type = Prize_None;
		[prize_icon setScale:0.6];
		tar_pos = ccp(0.5,0.5);
		v = [VecLib scale:[VecLib cons_x:cosf(i+[Common deg_to_rad:15]) y:sinf(i+[Common deg_to_rad:15]) z:0] by:0.41];
		tar_pos.x += v.x;
		tar_pos.y += v.y;
		[prize_icon setPosition:[Common pct_of_obj:wheel_bg pctx:tar_pos.x pcty:tar_pos.y]];
		[prizes addObject:prize_icon];
		[wheel_bg addChild:prize_icon];
	}
	[wheel_bg setScale:0.9];
	[wheel_bg addChild:wheel_pointer];
	
	
	spinbutton = [SpinButton cons_pt:[Common pct_of_obj:parent pctx:0.84 pcty:0.25]
								  cb:[Common cons_callback:self sel:@selector(spin)]];
	
	[self addChild:spinbutton];
	[touches addObject:spinbutton];
	
	wheel_pointer_vr = 0;
	wheel_pointer.rotation = float_random(-180, 180);
	
	[self conditional_refresh_prizes];
	
	return self;
}

#define KEY_PRIZEWHEEL(x) strf("key_prizewheel_%d",x)
#define SPIN_COST 500

+(int)get_spin_cost { return SPIN_COST; }

-(BOOL)conditional_refresh_prizes {
	if ([DailyLoginPrizeManager daily_wheel_reset_open]) {
		[self reload_prizes];
		[DailyLoginPrizeManager take_daily_wheel_reset];
		return YES;
		
	} else {
		for (int i = 0; i < prizes.count; i++) {
			PrizeIcon *itr = prizes[i];
			Prize tar_type = [DataStore get_int_for_key:KEY_PRIZEWHEEL(i)];
			
			if (itr.prize_type != tar_type) {
				itr.prize_type = tar_type;
				itr.textureRect = [FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:[self texkey_for_prize_type:tar_type]];
			}
		}
		return NO;
		
	}
	
}


-(void)reload_prizes {
	Prize manycoin = Prize_ManyCoin;
	Prize manybone = Prize_ManyBone;
	Prize coin = Prize_Coin;
	Prize bone = Prize_Bone;
	Prize mystery = Prize_Mystery;
	
	NSMutableArray *in_prizes = _NSMARRAY(
		NSVEnum(mystery, Prize),
		NSVEnum(manycoin, Prize),
		NSVEnum(manycoin, Prize),
		NSVEnum(manybone, Prize),
		NSVEnum(coin, Prize),
		NSVEnum(coin, Prize),
		NSVEnum(coin, Prize),
		NSVEnum(coin, Prize),
		NSVEnum(coin, Prize),
		NSVEnum(bone, Prize),
		NSVEnum(bone, Prize),
		NSVEnum(bone, Prize)
										  
	);
	[in_prizes shuffle];
	
	NSMutableArray *open_slots = [NSMutableArray array];
	for (int i = 0; i < prizes.count; i++) [open_slots addObject:[NSNumber numberWithInt:i]];
	[open_slots shuffle];
	
	for (PrizeIcon *i in prizes) {
		i.prize_type = Prize_None;
		[i setTextureRect:CGRectZero];
	}
	while(in_prizes.count > 0) {
		int slot = [open_slots.lastObject intValue];
		Prize tar_type;
		[in_prizes.lastObject getValue:&tar_type];
		PrizeIcon *tar = prizes[slot];
		
		[open_slots removeLastObject];
		[in_prizes removeLastObject];
		
		tar.prize_type = tar_type;
		[tar setTextureRect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:[self texkey_for_prize_type:tar_type]]];
	}
	
	for (int i = 0; i < prizes.count; i++) {
		PrizeIcon *itr = prizes[i];
		[DataStore set_key:KEY_PRIZEWHEEL(i) int_value:itr.prize_type];
	}
}

-(NSString*)texkey_for_prize_type:(Prize)tar {
	NSString *texkey = @"";
	if (tar == Prize_ManyCoin) {
		texkey = @"menu_prize_manycoin";
	} else if (tar == Prize_ManyBone) {
		texkey = @"menu_prize_manybone";
	} else if (tar == Prize_Coin) {
		texkey = @"menu_prize_fewcoin";
	} else if (tar == Prize_Bone) {
		texkey = @"menu_prize_fewbone";
	} else if (tar == Prize_Mystery) {
		texkey = @"menu_prize_mystery";
	}
	return texkey;
}

-(void)refresh_page {
	BOOL time_ok = NO;
	
	if (mode == PrizesPaneMode_REST) {
		time_ok = YES;
	}
	
	BOOL bones_ok = NO;
	if ([UserInventory get_current_bones] >= SPIN_COST) {
		bones_ok = YES;
	}
	
	if (!time_ok) {
		[spinbutton lock_time_string:@"Wait!"];
		
	} else if (!bones_ok) {
		[spinbutton lock_bones:SPIN_COST];
		
	} else {
		[spinbutton unlock_cost:SPIN_COST];
		
	}
	
	[cur_coins_disp set_label:strf("%d",[UserInventory get_current_coins])];
	[cur_bones_disp set_label:strf("%d",(int)disp_bones)];
	
	disp_bones = drp(disp_bones,[UserInventory get_current_bones],7);
	if (ABS(disp_bones - [UserInventory get_current_bones]) < 2) disp_bones = [UserInventory get_current_bones];
}

-(void)give_prize:(Prize)t start:(CGPoint)start {
	
	if (t == Prize_None) {
		[AudioManager mute_music_for:20];
		[AudioManager playsfx:SFX_FANFARE_LOSE];
		[AudioManager playsfx:SFX_FAIL];
		
	} else {
		[AudioManager mute_music_for:20];
		[AudioManager playsfx:SFX_FANFARE_WIN];
		[AudioManager playsfx:SFX_CHECKPOINT];
		
		[self add_particle:[[BoneCollectUIAnimation_Particle cons_start:start
																	end:ccp(0,0)]
							set_texture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
							rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:[self texkey_for_prize_type:t]]]];
		
		
		if (t == Prize_ManyCoin) {
			[UserInventory add_coins:3];
			
		} else if (t == Prize_ManyBone) {
			[self add_particle:[ShopBuyFlyoffTextParticle cons_pt:CGPointAdd(cur_bones_disp.position, ccp(25/CC_CONTENT_SCALE_FACTOR(),60/CC_CONTENT_SCALE_FACTOR()))
															 text:strf("+%d",1500) color:ccc3(30,200,30)]];
			[UserInventory add_bones:1500];
			
		} else if (t == Prize_Coin) {
			[UserInventory add_coins:1];
			
		} else if (t == Prize_Bone) {
			[self add_particle:[ShopBuyFlyoffTextParticle cons_pt:CGPointAdd(cur_bones_disp.position, ccp(25/CC_CONTENT_SCALE_FACTOR(),60/CC_CONTENT_SCALE_FACTOR()))
															 text:strf("+%d",500) color:ccc3(30,200,30)]];
			[UserInventory add_bones:500];
			
		} else if (t == Prize_Mystery) {
			
			if (![UserInventory get_character_unlocked:TEX_DOG_RUN_2]) {
				[MenuCommon popup:[DailyLoginPopup character_unlock_popup:TEX_DOG_RUN_2]];
				[UserInventory unlock_character:TEX_DOG_RUN_2];
				
			} else if (![UserInventory get_character_unlocked:TEX_DOG_RUN_5] && float_random(0, 5) < 1) {
				[MenuCommon popup:[DailyLoginPopup character_unlock_popup:TEX_DOG_RUN_5]];
				[UserInventory unlock_character:TEX_DOG_RUN_5];
				
			} else {
				NSString *val = [ExtrasManager random_unowned_extra];
				if (val != NULL) {
					[ExtrasManager set_own_extra_for_key:val];
					[MenuCommon popup:[ExtrasUnlockPopup cons_unlocking:val]];
				} else {
					
					
					BasePopup *p = [DailyLoginPopup cons];
					[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.5 pcty:0.875]
												 color:ccc3(20,20,20)
											  fontsize:35
												   str:@"Mystery Prize Get!"]];
					[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.5 pcty:0.75]
												 color:ccc3(20,20,20)
											  fontsize:15
												   str:@"You got 5 coins!"]];
					[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.5 pcty:0.675]
												 color:ccc3(20,20,20)
											  fontsize:12
												   str:@"(Looks like you've got all the prizes...for now!)"]];
					[p addChild:[[CCSprite spriteWithTexture:[Resource get_tex:TEX_ITEM_SS]
														rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"star_coin"]]
								  pos:[Common pct_of_obj:p pctx:0.425 pcty:0.5]]];
					[p addChild:[Common cons_label_pos:[Common pct_of_obj:p pctx:0.5325 pcty:0.5]
												 color:ccc3(200,30,30)
											  fontsize:12
												   str:@"x"]];
					[p addChild:[[Common cons_label_pos:[Common pct_of_obj:p pctx:0.575 pcty:0.5]
												  color:ccc3(200,30,30)
											   fontsize:25
													str:strf("%d",5)] anchor_pt:ccp(0,0.5)]];
					[UserInventory add_coins:5];
					[MenuCommon popup:p];
					
				}
			}
			
		}
	}
}

-(void)spin {
	if (mode != PrizesPaneMode_REST) return;
	if ([UserInventory get_current_bones] < SPIN_COST) return;
	[TrackingUtil track_evt:TrackingEvt_SpinWheel];
	
	for (float i = 0; i < 2*M_PI-0.1; i+=M_PI/4) {
		CGPoint vel = ccp(sinf(i),cosf(i));
		float scale = float_random(5, 7);
		Particle *p = [ShopBuyBoneFlyoutParticle cons_pt:spinbutton.position vel:ccp(vel.x*scale,vel.y*scale)];
		[p setTextureRect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"goldenbone"]];
		[self add_particle:p];
	}
	[self add_particle:[ShopBuyFlyoffTextParticle cons_pt:CGPointAdd(cur_bones_disp.position, ccp(25,60))
													 text:strf("-%d",SPIN_COST)]];
	[AudioManager playsfx:SFX_CHECKPOINT];
	
	[UserInventory add_bones:-SPIN_COST];
	mode = PrizesPaneMode_SPINNING;
	wheel_pointer_vr = float_random(35, 45);
}

-(void)update {
	if (!self.visible || !self.parent.visible) return;
	
	NSMutableArray *toremove = [NSMutableArray array];
    for (Particle *i in particles) {
        [i update:(id)self];
        if ([i should_remove]) {
            [particle_holder removeChild:i cleanup:YES];
            [toremove addObject:i];
        }
    }
	[particles removeObjectsInArray:toremove];
	
	for (CCSprite *spr in lights) [spr setTextureRect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"menu_wheel_light_off"]];
	for (id b in touches) if ([b respondsToSelector:@selector(update)]) [b update];
	[self refresh_page];
	
	Vec3D v = [VecLib cons_x:cosf([Common deg_to_rad:wheel_pointer.rotation+90]) y:sinf([Common deg_to_rad:wheel_pointer.rotation+90]) z:0];
	float rad = fmodf([Common deg_to_rad:[VecLib get_rotation:v offset:0]],(3.14*2));
	if (rad < 0) rad = 3.14*2 - ABS(rad);
	int i_tar = rad / (3.14/6);
	
	if (i_tar > lights.count) {
		i_tar = 0;
	}
	CCSprite *light = lights[i_tar];
	[light setTextureRect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"menu_wheel_light_on"]];
	
	[reset_in_disp set_label:[MenuCommon secs_to_prettystr:[DailyLoginPrizeManager get_time_until_new_day]]];
	
	if (mode == PrizesPaneMode_SPINNING) {
		[wheel_pointer setRotation:wheel_pointer.rotation + wheel_pointer_vr * [Common get_dt_Scale]];
		if (wheel_pointer_vr > 0.1 && wheel_pointer_vr * 0.95 < 0.1) {
			wheel_pointer_vr = 0;
			
			PrizeIcon *tar_obj = prizes[i_tar];
			[self give_prize:tar_obj.prize_type start:CGPointAdd([tar_obj convertToWorldSpace:CGPointZero],ccp(-50,-50))];
			[DataStore set_key:KEY_PRIZEWHEEL(i_tar) int_value:Prize_None];
			mode = PrizesPaneMode_REST;
		}
		wheel_pointer_vr *= 0.975;
		
		if (i_tar != last_light) [AudioManager playsfx:SFX_BONE];
		last_light = i_tar;
		
	} else if (mode == PrizesPaneMode_REST) {
		[self conditional_refresh_prizes];
		
	}
}

-(void)add_particle:(Particle*)p {
	[particle_holder addChild:p];
	[particles addObject:p];
}

-(void)setVisible:(BOOL)visible {
	if (visible) [self refresh_page];
	[super setVisible:visible];
}

-(void)touch_begin:(CGPoint)pt {
	if (!self.visible) return;
	for (TouchButton *b in touches) if (b.visible) [b touch_begin:pt];
}

-(void)touch_move:(CGPoint)pt {
	if (!self.visible) return;
	for (TouchButton *b in touches) if (b.visible) [b touch_move:pt];
}

-(void)touch_end:(CGPoint)pt {
	if (!self.visible) return;
	for (TouchButton *b in touches) if (b.visible) [b touch_end:pt];
}

-(void)set_pane_open:(BOOL)t {
	[self setVisible:t];
}

@end

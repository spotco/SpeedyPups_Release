#import "GameItemCommon.h"
#import "Resource.h"
#import "FileCache.h"
#import "GameEngineLayer.h"
#import "DogRocketEffect.h"
#import "UserInventory.h"
#import "AudioManager.h"
#import "ScoreManager.h"

@implementation NSValue (valueWithETest)
+(NSValue*) valueWithGameItem:(GameItem)g {
    return [NSValue value:&g withObjCType: @encode(GameItem)];
}
@end

@implementation GameItemCommon

static NSDictionary* names;
static NSDictionary* descriptions;
static NSDictionary* texrects;

+(void)cons_after_textures_loaded {
    names = @{
        [NSValue valueWithGameItem:Item_Heart]: @"Heart",
        [NSValue valueWithGameItem:Item_Magnet]: @"Magnet",
        [NSValue valueWithGameItem:Item_Rocket]: @"Rocket",
        [NSValue valueWithGameItem:Item_Shield]: @"Shield",
		[NSValue valueWithGameItem:Item_Clock]: @"Clock"
    };
    
    descriptions = @{
        [NSValue valueWithGameItem:Item_Heart]: @"Carry it to take an extra hit from any obstable.",
        [NSValue valueWithGameItem:Item_Magnet]: @"Bones and other goodies will fly your way!",
        [NSValue valueWithGameItem:Item_Rocket]: @"Zoom past your troubles!",
        [NSValue valueWithGameItem:Item_Shield]: @"Brief invincibility. Break past anything!",
		[NSValue valueWithGameItem:Item_Clock]: @"Slow down time."
    };
	
	CCTexture2D* tex = [Resource get_tex:TEX_ITEM_SS]; //do after textures loaded
	texrects = @{
        [NSValue valueWithGameItem:Item_Heart]: [TexRect cons_tex:tex rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"item_heart"]],
        [NSValue valueWithGameItem:Item_Magnet]: [TexRect cons_tex:tex rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"item_magnet"]],
        [NSValue valueWithGameItem:Item_Rocket]: [TexRect cons_tex:tex rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"item_rocket"]],
        [NSValue valueWithGameItem:Item_Shield]: [TexRect cons_tex:tex rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"item_shield"]],
		[NSValue valueWithGameItem:Item_Clock]:[TexRect cons_tex:tex rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:@"item_clock"]]
	};
}

+(TexRect*)texrect_from:(GameItem)gameitem {	
	if (gameitem == Item_NOITEM) return [TexRect cons_tex:[Resource get_tex:TEX_ITEM_SS] rect:CGRectZero];
	TexRect *rtv = [texrects objectForKey:[NSValue valueWithGameItem:gameitem]];
	if (rtv == NULL) [NSException raise:@"unknown gameitem" format:@"%d",gameitem];
    return rtv;
	
}

+(TexRect*)object_textrect_from:(GameItem)type {
	CCTexture2D *tex = [Resource get_tex:TEX_ITEM_SS];
	NSString *tar = @"";
	if (type == Item_Magnet) {
		tar = @"pickup_magnet";
	} else if (type == Item_Clock) {
		tar = @"pickup_clock";
	} else if (type == Item_Rocket) {
		tar = @"pickup_rocket";
	} else if (type == Item_Shield) {
		tar = @"pickup_shield";
	}
	return [TexRect cons_tex:tex rect:[FileCache get_cgrect_from_plist:TEX_ITEM_SS idname:tar]];
}

+(NSString*)name_from:(GameItem)gameitem {
	if (gameitem == Item_NOITEM) return @"None";
	if ([UserInventory get_upgrade_level:gameitem] == 0)
		return [names objectForKey:[NSValue valueWithGameItem:gameitem]];
	
    return [names objectForKey:[NSValue valueWithGameItem:gameitem]];
}

+(NSString*)description_from:(GameItem)gameitem {
    return [descriptions objectForKey:[NSValue valueWithGameItem:gameitem]];
}

+(void)use_item:(GameItem)it on:(GameEngineLayer*)g clearitem:(BOOL)clearitem {
	if (g.player.dead) return;
	[AudioManager playsfx:SFX_POWERUP];
	
	[g.score increment_multiplier:0.1];
	[g.score increment_score:50];
	
    if (it == Item_Rocket) {
        [g.player add_effect:[DogRocketEffect cons_from:[g.player get_current_params] time:[self get_uselength_for:it g:g]]];
        
    } else if (it == Item_Magnet) {
        [g.player set_magnet_rad:250 ct:[self get_uselength_for:Item_Magnet g:g]];
        
    } else if (it == Item_Shield) {
        [g.player set_armored:[self get_uselength_for:Item_Shield g:g]];
        
    } else if (it == Item_Heart) {
        //[g.player set_heart:[self get_uselength_for:Item_Heart g:g]];
        NSLog(@"used heart??");
		
    } else if (it == Item_Clock) {
		[g.player set_clockeffect:[self get_uselength_for:Item_Clock g:g]];
		[GEventDispatcher push_event:[[[GEvent cons_type:GEventType_ITEM_DURATION_PCT] add_f1:1 f2:0] add_i1:Item_Clock i2:0]];
		[GameControlImplementation set_clockbutton_hold:YES];
		
	}
	
	if (clearitem) [UserInventory set_current_gameitem:Item_NOITEM];
}

+(int)get_uselength_for:(GameItem)gi g:(GameEngineLayer *)g {
	int uglvl = [UserInventory get_upgrade_level:gi];
	if (uglvl >= 4) {
		NSLog(@"error, upgrade level too high");
	}
	
	if ([g get_challenge] != NULL) {
		if (gi==Item_Clock) {
			int rtvs[] = {75,150,250,350};
			return rtvs[uglvl];
			
		}
		int rtvs[] = {100,200,300,500};
		return rtvs[uglvl];
		
	} else {
		if (gi==Item_Clock) {
			int rtvs[] = {100,200,300,400};
			return rtvs[uglvl];
			
		}
		int rtvs[] = {500,900,1500,2000};
		return rtvs[uglvl];
	}
}

+(NSString*)stars_for_level:(int)i {
	NSString *whitestar = @"\u2606";
	NSString *blackstar = @"\u2605";
	return [NSString stringWithFormat:@"%@%@%@",i>=1?blackstar:whitestar,i>=2?blackstar:whitestar,i>=3?blackstar:whitestar];
}

@end
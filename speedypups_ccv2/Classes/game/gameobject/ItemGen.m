#import "ItemGen.h"
#import "UserInventory.h"
#import "AudioManager.h"

@implementation ItemGen

+(ItemGen*)cons_pt:(CGPoint)pt {
	return [[ItemGen node] cons_pt:pt imm:NO item:0];
}

+(ItemGen*)cons_pt:(CGPoint)pt item:(GameItem)imm_item {
	return [[ItemGen node] cons_pt:pt imm:YES item:imm_item];
}

-(id)cons_pt:(CGPoint)pt imm:(BOOL)imm item:(GameItem)imm_item {
	immediate = imm;
	if (immediate) {
		item = imm_item;
		
	} else {
		NSValue *pickedvalue = [@[
			[NSValue valueWithGameItem:Item_Clock],
			[NSValue valueWithGameItem:Item_Magnet],
			[NSValue valueWithGameItem:Item_Rocket],
			[NSValue valueWithGameItem:Item_Shield]
		] random];
		[pickedvalue getValue:&item];
	}
	
	TexRect *img = [GameItemCommon object_textrect_from:item];
	[self setTexture:img.tex];
	[self setTextureRect:img.rect];
	[self setPosition:pt];
	initial_pos = pt;
	active = YES;
	[self csf_setScale:1.5];
	
	return self;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-15 y1:[self position].y-15 wid:30 hei:30];
}

-(void)hit {
	if (immediate) {
		[GameItemCommon use_item:item on:gameengine clearitem:NO];
		
	} else {
	    [UserInventory set_current_gameitem:item];
		[GEventDispatcher push_event:[GEvent cons_type:GEVentType_PICKUP_ITEM]];
	}
	
	[AudioManager playsfx:SFX_POWERUP];
	active = NO;
}

-(void)reset {
    [self setPosition:initial_pos];
    follow = NO;
    vx = 0;
    vy = 0;
    
	active = YES;
}

@end

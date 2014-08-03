#import "UIWaterAlert.h"
#import "GameEngineLayer.h"
#import "Resource.h"
#import "FileCache.h"
#import "Water.h"
#import "UICommon.h"

@implementation UIWaterAlert

+(UIWaterAlert*)cons {
	return [UIWaterAlert node];
}

-(id)init {
	self = [super init];
	
	body = [CSF_CCSprite node];
	[body runAction:[Common cons_anim:@[@"water_warning_0",@"water_warning_1"] speed:0.2 tex_key:TEX_UI_INGAMEUI_SS]];
	[body setAnchorPoint:ccp(0.5,0)];
	[body setPosition:[Common screen_pctwid:0.5 pcthei:0.01]];
	[self addChild:body];
	[body setVisible:NO];
	
	return self;
}

-(void)update:(GameEngineLayer *)g {
	Water *closest_water = NULL;
	float dist = INFINITY;
	CGPoint playerpt = g.player.position;
	
	for (GameObject *o in g.game_objects) {
		if ([[o class] isSubclassOfClass:[Water class]]) {
			Water *cur = (Water*)o;
			CGPoint size = [cur get_size];
			CGRange x_range, y_range;
			x_range.min = cur.position.x - 600;
			x_range.max = cur.position.x + size.x + 600;
			y_range.min = cur.position.y + size.y + 300;
			y_range.max = cur.position.y + size.y + 2500;
			if (playerpt.x > x_range.min && playerpt.x < x_range.max && playerpt.y > y_range.min && playerpt.y < y_range.max) {
				float curdist = CGPointDist(g.player.position, ccp(cur.position.x+size.x/2,cur.position.y+size.y));
				if (curdist < dist) {
					closest_water = cur;
					dist = curdist;
				}
			}
		}
	}
	if (closest_water == NULL) {
		[body setVisible:NO];
		return;
	}
	
	//CGPoint water_min = [UICommon pt_approx_position:closest_water.position g:g];
	//CGPoint water_max = [UICommon pt_approx_position:ccp(closest_water.position.x+closest_water.get_size.x,closest_water.position.y) g:g];
	
	CGPoint water_min = [UICommon game_to_screen_pos:closest_water.position g:g];
	CGPoint water_max = [UICommon game_to_screen_pos:ccp(closest_water.position.x+closest_water.get_size.x,closest_water.position.y) g:g];
	CGPoint set_position = ccp([Common SCREEN].width*0.5,body.position.y);
	set_position.x = clampf(set_position.x, water_min.x, water_max.x);
	[body setPosition:set_position];
	[body setVisible:YES];
}

@end

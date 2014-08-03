#import "UIEnemyAlert.h"
#import "Resource.h"
#import "FileCache.h"
#import "GameEngineLayer.h"
#import "LauncherRocket.h"

@implementation UIEnemyAlert

+(UIEnemyAlert*)cons {
	return [UIEnemyAlert node];
}

-(id)init {
	self = [super init];
	
	mainbody = [CSF_CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
									  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"enemy_approach_ui"]];
	
	arrow = [CCSprite spriteWithTexture:[Resource get_tex:TEX_UI_INGAMEUI_SS]
									  rect:[FileCache get_cgrect_from_plist:TEX_UI_INGAMEUI_SS idname:@"enemy_approach_ui_arrow"]];
	
	[self addChild:mainbody];
	[mainbody addChild:arrow];
	[self set_dir:[VecLib cons_x:1 y:0 z:0]];
	return self;
}

-(void)set_flash:(BOOL)v {
	[arrow setVisible:v];
}

-(void)set_dir:(Vec3D)dir {
	
	[arrow setRotation:[VecLib get_rotation:dir offset:45]];
	dir = [VecLib scale:dir by:40/CC_CONTENT_SCALE_FACTOR()];
	CGPoint centre = [Common pct_of_obj:mainbody pctx:0.5 pcty:0.5];
	centre.x += dir.x;
	centre.y += dir.y;
	[arrow setPosition:centre];
}

-(void)set_ct:(int)ct {
	enemy_alert_ui_ct = ct;
}

#define ENEMY_ALERT_CENTER [Common screen_pctwid:0.6 pcthei:0.5]

-(void)update:(GameEngineLayer*)g {
    if (enemy_alert_ui_ct > 0) {
		float min_rocket_dist = INFINITY;
		Vec3D alert_delta = [VecLib cons_x:1 y:0 z:0];
		BOOL found = NO;
		for (GameObject *o in g.game_objects) {
			if ([[o class] isSubclassOfClass:[LauncherRocket class]] && o.position.x > g.player.position.x-200 ) {
				if (![(LauncherRocket*)o is_active]) continue;
				float dist = CGPointDist(o.position, g.player.position);
				if (dist < min_rocket_dist) {
					min_rocket_dist = dist;
					alert_delta = [VecLib normalized_x:o.position.x-g.player.position.x y:o.position.y-g.player.position.y z:0];
					found = YES;
				}
			}
		}
		
		[self set_dir:alert_delta];
		alert_delta = [VecLib scale:alert_delta by:[Common SCREEN].width*0.25];
		CGPoint alert_pos = ENEMY_ALERT_CENTER;
		alert_pos.x += alert_delta.x;
		alert_pos.y += alert_delta.y;
		[self setPosition:alert_pos];
		
        enemy_alert_ui_ct-=[Common get_dt_Scale];
        [self set_flash:(((int)enemy_alert_ui_ct)/14)%2];
		[self setVisible:found];
		
    } else {
        [self setVisible:NO];
    }
}

@end

#import "RocketWall.h"
#import "GameEngineLayer.h"
#import "LauncherRocket.h"
#import "ExplosionParticle.h"
#import "DogRocketEffect.h"
#import "GameItemCommon.h"

@implementation RocketWall

+(RocketWall*)cons_x:(float)x y:(float)y width:(float)width height:(float)height {
    RocketWall *w = [RocketWall node];
    [w cons_x:x y:y width:width height:height];
    return w;
    
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (player.position.x - 3000 > [self position].x) {
        return;
    }
    if (to_remove == NULL) {
		to_remove = [NSMutableArray array];
	}
    for (GameObject *o in g.game_objects) {
        if ([[o class] isSubclassOfClass:[LauncherRocket class]] && [Common hitrect_touch:[self get_hit_rect] b:[o get_hit_rect]]) {
			[g add_particle:[ExplosionParticle cons_x:o.position.x y:o.position.y]];
            [to_remove addObject:o];
        }
    }
    for (LauncherRocket *o in to_remove) {
        //[g remove_gameobject:[o get_shadow]];
		[g remove_gameobject:o];
    }
    [to_remove removeAllObjects];
}

@end

@implementation DogRocketWall

+(DogRocketWall*)cons_x:(float)x y:(float)y width:(float)width height:(float)height {
    DogRocketWall *w = [DogRocketWall node];
    [w cons_x:x y:y width:width height:height];
    return w;
}
-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if ([[player get_current_params] class] == [DogRocketEffect class] && [Common hitrect_touch:[player get_hit_rect] b:[self get_hit_rect]]) {
		[player remove_temp_params:g];
	}
	if ([player is_armored] && [Common hitrect_touch:[player get_hit_rect] b:[self get_hit_rect]]) {
		[player end_armored];
	}
}

@end

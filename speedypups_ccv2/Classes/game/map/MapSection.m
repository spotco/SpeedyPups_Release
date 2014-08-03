#import "MapSection.h"
#import "Island.h"
#import "GameObject.h"
#import "GameEngineLayer.h"

#define DOTMAP @"map"

@implementation MapSection
@synthesize map;
@synthesize stop_repool;

+(MapSection*)cons_from_name:(NSString*)name g:(GameEngineLayer*)g {
    MapSection* m = [[MapSection alloc] init];
    [m cons:name g:g];
    return m;
}

-(void)cons:(NSString*)name g:(GameEngineLayer*)g {
	if ([g get_challenge]) {
		[MapLoader set_maploader_mode:MapLoaderMode_CHALLENGE];
	}
    map = [MapLoader load_map:name g:g];
	
	[MapLoader set_maploader_mode:MapLoaderMode_AUTO];
	
	if (map == NULL) {
		NSLog(@"ERROR::map is null for %@",name);
	}
    [MapSection transform_map:map by_x:-map.connect_pts_x1 by_y:-map.connect_pts_y1];
    offset_x = 0;
    offset_y = 0;
	stop_repool = NO;
    [self alloc_debugid];
}

-(MapSection_Position)get_position_status:(CGPoint)p {
    CGRange range = [self get_range];
    float min = range.min;
    float max = range.max;
    
    if (p.x >= min && p.x <= max) {
        return MapSection_Position_CURRENT;
    } else if (p.x < min) {
        return MapSection_Position_AHEAD;
    } else if (p.x > max) {
        return MapSection_Position_PAST;
    } else {
        NSLog(@"mapsection code error sur (%@)",NSStringFromCGPoint(p));
        return MapSection_Position_CURRENT;
    }
}

-(CGPoint)get_offset {
    return ccp(offset_x,offset_y);
}

-(CGRange)get_range {
    struct CGRange r;
    r.min = offset_x;
    r.max = offset_x + (map.connect_pts_x2 - map.connect_pts_x1);
    return r;
}

-(void)offset_x:(float)x y:(float)y {
    offset_x += x;
    offset_y += y;
    [MapSection transform_map:map by_x:x by_y:y];
}

+(void)transform_map:(GameMap*)map by_x:(float)tx by_y:(float)ty {
    for (Island* i in map.n_islands) {
        [i setPosition:ccp(i.position.x+tx,i.position.y+ty)];
        i.startX +=tx;
        i.startY +=ty;
        i.endX +=tx;
        i.endY +=ty;
    }
    for (GameObject* o in map.game_objects) {
        [o autolevel_set_position:ccp(o.position.x+tx,o.position.y+ty)];
    }
}

-(void)dealloc {
	if (!stop_repool) {
		for (GameObject *o in map.game_objects) {
			[o repool];
		}
		for (Island *i in map.n_islands) {
			[i repool];
		}
	}
    [map.game_objects removeAllObjects];
    [map.n_islands removeAllObjects];
}

static int debugct = 0;
-(void)alloc_debugid {
    debugid = debugct;
    debugct++;
}
-(int)get_debugid {
    return debugid;
}

@end
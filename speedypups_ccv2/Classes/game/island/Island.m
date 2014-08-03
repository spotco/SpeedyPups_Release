#import "Island.h"
#import "GameRenderImplementation.h"

@implementation Island

static float NO_VAL = -99999.0;

+(float) NO_VALUE {
    return NO_VAL;
}

@synthesize startX, startY, endX, endY, fill_hei, ndir, t_min, t_max;
@synthesize next,prev;
@synthesize can_land;

+(int) link_islands:(NSMutableArray*)islands {
    int ct = 0;
    for(Island *i in islands) {
        if (i.next != NULL) {
            continue;
        }
        
        for(Island *j in islands) {
            if ([Common pt_fuzzy_eq:ccp(i.endX,i.endY) b:ccp(j.startX,j.startY)]) {
                i.next = j;
                j.prev = i;
                ct++;
                break;
            }
        }
    }
    for (Island *i in islands) {
        [i link_finish];
    }
    for (Island *i in islands) {
        [i post_link_finish];
    }
    return ct;
}

-(void)post_link_finish {}

-(int)get_render_ord {
    if (can_land == NO) {
        return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
    } else {
        return [GameRenderImplementation GET_RENDER_ISLAND_ORD];
    }
}

-(float)get_height:(float)pos {
	if (pos < startX || pos > endX) {
		return [Island NO_VALUE];
	} else {
		return startY+(pos-startX)*((endY-startY)/(endX-startX));
	}
}

-(void)link_finish {}

-(void)check_should_render:(GameEngineLayer *)g {
    
}

-(Vec3D)calc_normal_vec {
    Vec3D line_vec = [VecLib cons_x:endX-startX y:endY-startY z:0];
    Vec3D normal_vec = [VecLib cross:[VecLib Z_VEC] with:line_vec];
    normal_vec = [VecLib normalize:normal_vec];
    normal_vec = [VecLib scale:normal_vec by:ndir];
    return normal_vec;
}

-(Vec3D)get_normal_vecC {
    return [self calc_normal_vec];
}

-(line_seg)get_line_seg {
    return [Common cons_line_seg_a:ccp(startX,startY) b:ccp(endX,endY)];
}

-(Vec3D)get_tangent_vec {
    return [VecLib normalized_x:endX-startX y:endY-startY z:0];
}

-(float)get_t_given_position:(CGPoint)position {
    float dx = powf(position.x - startX, 2);
    float dy = powf(position.y - startY, 2);
    float f = sqrtf( dx+dy );
    return f;
}

-(CGPoint)get_position_given_t:(float)t {
    if (t > t_max || t < t_min) {
        return ccp([Island NO_VALUE],[Island NO_VALUE]);
    } else {
        float frac = t/t_max;
        Vec3D dir_vec = [VecLib cons_x:endX-startX y:endY-startY z:0];
        dir_vec = [VecLib scale:dir_vec by:frac];
        CGPoint pos = ccp(startX+dir_vec.x,startY+dir_vec.y);
        return pos;
    }
}

-(void)set_pt1:(CGPoint)start pt2:(CGPoint)end {
	startX = start.x;
	startY = start.y;
	endX = end.x;
	endY = end.y;
}

-(HitRect)get_hitrect {
    return [Common hitrect_cons_x1:0 y1:0 wid:0 hei:0];
}

-(void)cleanup_anims {}
-(void)repool{}



- (NSString *)description {
    return strf("[LineIsland(%f,%f)->(%f,%f)]",startX,startY,endX,endY);
}

@end

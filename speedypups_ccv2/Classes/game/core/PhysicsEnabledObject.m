#import "PhysicsEnabledObject.h"

#import "GameEngineLayer.h"
#import "GamePhysicsImplementation.h"

@implementation PhysicsEnabledObject

#define DEFAULT_GRAVITY -0.5
#define DEFAULT_MIN_SPEED 7

#define MIN_SPEED_MAX 14
#define LIMITSPD_INCR 2

#define DEFAULT_HITBOX_RESCALE 0.3

@synthesize up_vec;
@synthesize current_swingvine;
@synthesize current_cannon;
@synthesize floating;
@synthesize current_island;
@synthesize last_ndir,movedir;
@synthesize vx,vy;
@synthesize params;
@synthesize IMGWID,IMGHEI,movex;

@synthesize starting_position;

+(PhysicsEnabledObject*)cons_x:(float)x y:(float)y {
    PhysicsEnabledObject *r = [PhysicsEnabledObject spriteWithTexture:[Resource get_tex:TEX_ENEMY_ROBOT] 
                                               rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"]];
    [r setPosition:ccp(x,y)];
    [r setStarting_position:ccp(x,y)];
    [r setIMGWID:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"].size.width];
    [r setIMGHEI:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"].size.height];
    return r;
}

-(id)init {
    self = [super init];
    //[self setAnchorPoint:ccp(0.5,0)];
    self.active = YES;
    refresh_hitrect = YES;
    [self reset_physics_params];
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    [super update:player g:g];
    [GamePhysicsImplementation player_move:self with_islands:g.islands];
    if (![Common hitrect_touch:[self get_hit_rect] b:[g get_world_bounds]]) {
        [self fall_out];
    }
    refresh_hitrect = YES;
    
    [self move];
}

-(void)move {
    if (current_island != NULL) {
        vx = movex;
        vy = 0;
        movedir = [Common sig:movex];
    }
}

-(void)fall_out {
    [self setPosition:starting_position];
    [self reset_physics_params];
}

-(PlayerEffectParams*)get_current_params {
    return params;
}

-(int)get_speed {
    return 7;
}

-(void)reset_physics_params {
    up_vec = [VecLib cons_x:0 y:1 z:0];
    if (params) {
        [params effect_end];
    }
    
    params = [[PlayerEffectParams alloc] init];
    params.cur_gravity = DEFAULT_GRAVITY;
    params.cur_airjump_count = 1;
    params.cur_dash_count = 1;
    params.time_left = -1;
    
    //rotation_ = 0;
    [self setRotation:0];
	movedir = 1;
    current_swingvine = NULL;
    floating = NO;
    current_island = NULL;
    last_ndir = 1;
    vx = vy = 0;
}

-(HitRect)get_hit_rect {
    return [self get_hit_rect_rescale:DEFAULT_HITBOX_RESCALE];
}

-(HitRect) get_hit_rect_rescale:(float)rsc {
    if ([self get_current_params].noclip) {
        return [Common hitrect_cons_x1:0 y1:0 wid:0 hei:0];
    } else if (refresh_hitrect == NO) {
        return cached_rect;
    }
    
    Vec3D v = [VecLib cons_x:up_vec.x y:up_vec.y z:0];
    Vec3D h = [VecLib cross:v with:[VecLib Z_VEC]];
    float x = self.position.x;
    float y = self.position.y;
    h=[VecLib normalize:h];
    v=[VecLib normalize:v];
    h=[VecLib scale:h by:IMGWID/2 * rsc];
    v=[VecLib scale:v by:IMGHEI *rsc];
    CGPoint pts[4];
    pts[0] = ccp(x-h.x , y-h.y);
    pts[1] = ccp(x+h.x , y+h.y);
    pts[2] = ccp(x-h.x+v.x , y-h.y+v.y);
    pts[3] = ccp(x+h.x+v.x , y+h.y+v.y);
    
    float x1 = pts[0].x;
    float y1 = pts[0].y;
    float x2 = pts[0].x;
    float y2 = pts[0].y;
    
    for (int i = 0; i < 4; i++) {
        x1 = MIN(pts[i].x,x1);
        y1 = MIN(pts[i].y,y1);
        x2 = MAX(pts[i].x,x2);
        y2 = MAX(pts[i].y,y2);
    }
    
    refresh_hitrect = NO;
    cached_rect = [Common hitrect_cons_x1:x1 y1:y1 x2:x2 y2:y2];
    return cached_rect;
}

-(void)print:(HitRect)r {
    NSLog(@"viewbox:(%f,%f) (%f,%f)",r.x1,r.y1,r.x2,r.y2);
}


@end
